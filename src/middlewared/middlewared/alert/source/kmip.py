from middlewared.alert.base import AlertClass, SimpleOneShotAlertClass, AlertCategory, AlertLevel


class KMIPConnectionFailedAlertClass(AlertClass, SimpleOneShotAlertClass):
    category = AlertCategory.KMIP
    level = AlertLevel.CRITICAL
    title = 'Failed To Communicate With KMIP Server'
    text = 'Failed to connect to %(server)s KMIP Server: %(error)s'

    deleted_automatically = False


class KMIPZFSDatasetsSyncFailureAlertClass(AlertClass, SimpleOneShotAlertClass):
    category = AlertCategory.KMIP
    level = AlertLevel.CRITICAL
    title = 'Failed To Sync ZFS Keys With KMIP Server'
    text = 'Failed to sync %(datasets)s dataset(s) keys with KMIP Server'

    deleted_automatically = False


class KMIPSEDDisksSyncFailureAlertClass(AlertClass, SimpleOneShotAlertClass):
    category = AlertCategory.KMIP
    level = AlertLevel.CRITICAL
    title = 'Failed To Sync SED Keys With KMIP Server'
    text = 'Failed to sync %(disks)s disk(s) keys with KMIP Server'

    deleted_automatically = False


class KMIPSEDGlobalPasswordSyncFailureAlertClass(AlertClass, SimpleOneShotAlertClass):
    category = AlertCategory.KMIP
    level = AlertLevel.CRITICAL
    title = 'Failed To Sync SED Global Password With KMIP Server'
    text = 'Failed to sync SED global password with KMIP Server'

    deleted_automatically = False
