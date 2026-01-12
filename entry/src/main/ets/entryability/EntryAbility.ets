import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import relationalStore from '@ohos.data.relationalStore';

export class GlobalRdbStore {
  static rdbStore: relationalStore.RdbStore
}

interface StoreConfig {
  name: string;
  securityLevel: relationalStore.SecurityLevel;
  encrypt?: boolean;
}

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  public async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');

    const CONTACTSTREE_CONFIG: StoreConfig = {
      name: 'ContactsTreeDB.db',
      securityLevel: relationalStore.SecurityLevel.S1,
      encrypt: false
    }

    const SQL_CREATE_CONTACTS_TABLE = `
    CREATE TABLE IF NOT EXISTS contacts (
      id INTEGER PRIMARY KEY,
      key TEXT NOT NULL,
      name TEXT NOT NULL,
      phone TEXT NOT NULL
    )
    `;

    const SQL_CREATE_GROUPS_TABLE = `
    CREATE TABLE IF NOT EXISTS groups (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE
    )
    `;

    const SQL_CREATE_CONTACT_GROUPS_TABLE = `
    CREATE TABLE IF NOT EXISTS contact_groups (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      contact_id INTEGER NOT NULL,
      group_id INTEGER NOT NULL,
      FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE,
      FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE,
      UNIQUE(contact_id, group_id)
    )
    `;

    try {
      GlobalRdbStore.rdbStore = await relationalStore.getRdbStore(this.context, CONTACTSTREE_CONFIG);
      await GlobalRdbStore.rdbStore.executeSql(SQL_CREATE_CONTACTS_TABLE);
      await GlobalRdbStore.rdbStore.executeSql(SQL_CREATE_GROUPS_TABLE);
      await GlobalRdbStore.rdbStore.executeSql(SQL_CREATE_CONTACT_GROUPS_TABLE);
    } catch (error) {
      hilog.error(DOMAIN, 'DataAbility', 'RDB error: %{public}s', JSON.stringify(error));
    }

  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}