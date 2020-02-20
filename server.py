import firebase_admin
import google.cloud
from firebase_admin import credentials, firestore
from firebase_admin.firestore import SERVER_TIMESTAMP
import time
from py_irsend import irsend
import threading
from datetime import datetime
import threading
import smbus
from gpiozero import RGBLED

TEMP_ADDRESS = 0x60
led = RGBLED(13, 19, 26)

firCredentials = credentials.Certificate(
    './fit5140ass3-firebase-adminsdk-hs421-3c5c0b798c.json')
firApp = firebase_admin.initialize_app(firCredentials)
firStore = firestore.client()
threadings = dict()


def syncCommands():
    """
    Sync all local commands to firebase
    """
    try:
        led.color = (1, 0, 0)
        print('syncing')
        for remote in irsend.list_remotes():
            for code in irsend.list_codes(remote):
                # From https://firebase.google.com/docs/firestore/query-data/queries
                docs = firStore.collection(u'Commands').where(
                    u'device', u'==', remote.decode()).where(u'remote', u'==', code.decode()).get()
                if len(list(docs)) == 0:
                    data = {
                        u'device': remote.decode(),
                        u'name': remote.decode() + ' ' + ' '.join(code.decode().split('_')).lower(),
                        u'remote': code.decode(),
                        u'voice': remote.decode() + ' ' + ' '.join(code.decode().split('_')).lower()
                    }
                    # From https://firebase.google.com/docs/firestore/manage-data/add-data
                    firStore.collection(u'Commands').add(data)
        print('sync finished')
        led.color = (0, 1, 0)
    except Exception as e:
        print(str(e))
        led.color = (1, 1, 0)


def executeCommand(device, command):
    """
    Execute a command
    ie: Update the only document in CurrentCommand collection on firebase
    """
    try:
        led.color = (1, 0, 1)
        if device.encode() in irsend.list_remotes() and command.encode() in irsend.list_codes(device):
            irsend.send_once(device, [command])
            print('command ' + command + ' for ' + device + ' executed')
            led.color = (0, 1, 0)
    except Exception as e:
        print(str(e))
        led.color = (1, 1, 0)


def appRequest_on_snapshot(col_snapshot, changes, read_time):
    """
    Listen on app request
    """
    try:
        print(u'Callback received query snapshot.')
        for change in changes:
            if change.type.name == 'MODIFIED':
                print(u'modified: {}'.format(change.document))
                newData = {
                    'timestamp': SERVER_TIMESTAMP
                }
                firStore.collection(u'PiResponse').document(
                    u'piResponse').set(newData)
        led.color = (0, 1, 0)
    except Exception as e:
        print(str(e))
        led.color = (1, 1, 0)


def currentCommand_on_snapshot(col_snapshot, changes, read_time):
    """
    Listen on current command
    """
    try:
        for change in changes:
            if change.type.name == 'MODIFIED':
                # irsend.send_once(change.document.)
                current_command = change.document.to_dict()
                print(current_command)
                executeCommand(current_command['device'],
                               current_command['command'])
                # if current_command['device'].encode() in irsend.list_remotes() and current_command['command'].encode() in irsend.list_codes(current_command['device']):
                #     irsend.send_once(current_command['device'], [
                #                      current_command['command']])
                #     print('sent')
        led.color = (0, 1, 0)
    except Exception as e:
        print(str(e))
        led.color = (1, 1, 0)


def executeTask(id, device, command):
    """
    Execute a scheduled task
    """
    try:
        executeCommand(device, command)
        firStore.collection(u'ScheduledTasks').document(
            id).update({u'status': u'executed'})
        led.color = (0, 1, 0)
    except Exception as e:
        print(str(e))
        led.color = (1, 1, 0)


def cancelTask(id):
    """
    Cancel a scheduled task
    """
    if threadings.get(id):
        task = threadings.pop(id)
        task.cancel()
        try:
            firStore.collection(u'ScheduledTasks').document(
                id).update({u'status': u'canceled'})
            print('task ' + id + ' canceled')
            led.color = (0, 1, 0)
        except Exception as e:
            print('Error when canceling task : ' + str(e))
            led.color = (1, 1, 0)


def scheduledTasks_on_snapshot(col_snapshot, changes, read_time):
    """
    Listen on scheduled tasks
    """
    for change in changes:
        if change.type.name == 'ADDED':
            task = change.document.to_dict()
            future = datetime.fromtimestamp(task['timestamp'].timestamp())
            if future > datetime.now() and task['status'] == 'queried' and not threadings.get(change.document.id):
                newThread = threading.Timer(
                    (future - datetime.now()).total_seconds(), executeTask, (change.document.id, task['device'], task['command'],))
                newThread.start()
                threadings[change.document.id] = newThread
                print(future)
        if change.type.name == 'MODIFIED':
            task = change.document.to_dict()
            if task['status'] == 'canceled':
                cancelTask(change.document.id)
                print(task)


# A cancelable thread
# From https://src-bin.com/en/q/4f184
class TempWatcher(threading.Thread):
    def __init__(self, sleep_interval=1):
        super().__init__()
        self._kill = threading.Event()
        self._interval = sleep_interval

    def run(self, device, command):
        print('temp watcher started')
        bus = smbus.SMBus(1)
        # Enable Temp Sensor
        bus.write_byte_data(TEMP_ADDRESS, 0x26, 0xB9)
        bus.write_byte_data(TEMP_ADDRESS, 0x13, 0x07)
        bus.write_byte_data(TEMP_ADDRESS, 0x26, 0xB9)
        # Give sensor a second to initialize
        time.sleep(1)
        while True:
            data = bus.read_i2c_block_data(TEMP_ADDRESS, 0x00, 6)
            clear = ((data[4] * 256) + (data[5] & 0xF0))/16
            tempCel = clear / 16
            if tempCel > 30:
                executeCommand(device, command)
                firStore.collection(u'TempWatcher').document(
                    u'tempWatcher').update({u'status': u'done'})
                self._kill.set()
            print(tempCel)
            # If no kill signal is set, sleep for the interval,
            # If kill signal comes in while sleeping, immediately
            #  wake up and handle
            is_killed = self._kill.wait(self._interval)
            if is_killed:
                break

        print("Killing Thread")

    def kill(self):
        self._kill.set()


tempWatcher = TempWatcher()


# From https://firebase.google.com/docs/firestore/query-data/listen
def tempWatcher_on_snapshot(col_snapshot, changes, read_time):
    """
    Listen on temp watcher
    """
    change = changes[0]
    print(change)
    if change.type.name == 'MODIFIED':
        if change.document.id == 'tempWatcher':
            watcherStatus = change.document.to_dict()
            print(watcherStatus)
            if watcherStatus['status'] == 'watching':
                tempWatcher.run(
                    watcherStatus['device'], watcherStatus['command'])
            if watcherStatus['status'] == '1':
                tempWatcher.kill()
                print('killed')


syncCommands()


appRequest_col_query = firStore.collection(u'AppRequest')
appRequest_query_watch = appRequest_col_query.on_snapshot(
    appRequest_on_snapshot)

currentCommand_col_query = firStore.collection(u'CurrentCommand')
currentCommand_query_watch = currentCommand_col_query.on_snapshot(
    currentCommand_on_snapshot)

scheduledTasks_col_query = firStore.collection(u'ScheduledTasks')
scheduledTassks_query_watch = scheduledTasks_col_query.on_snapshot(
    scheduledTasks_on_snapshot)

tempWatcher_col_query = firStore.collection(u'TempWatcher')
tempWatcher_query_watch = tempWatcher_col_query.on_snapshot(
    tempWatcher_on_snapshot)

# Keep the program running
while True:
    time.sleep(1)
