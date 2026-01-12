import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import relationalStore from '@ohos.data.relationalStore';
import {Group} from '../types/Group';
import { Contact } from '../types/Contact';
import {GlobalRdbStore} from '../entryability/EntryAbility'

export async function getGroups(): Promise<Group[]> {
  const groups: Group[] = [];

  try {
    const predicates = new relationalStore.RdbPredicates('groups');
    const resultSet = await GlobalRdbStore.rdbStore.query(predicates, ['id', 'name']);

    while (resultSet.goToNextRow()) {
      groups.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name'))
      });
    }
    resultSet.close();

  } catch (error) {
    console.error(`Get groups failed, code: ${error.code}, message: ${error.message}`);
  }
  return groups;
}

export async function addGroup(name: string){
  if (!name || name.trim().length === 0) {
    throw new Error('Name cannot be empty');
  }

  try {
    const valueBucket: relationalStore.ValuesBucket = {
      'name': name.trim()
    };
    await GlobalRdbStore.rdbStore.insert('groups', valueBucket);
  } catch (error) {
    throw new Error(error);
  }
}

export async function updateGroup(groupId: number, newGroupName: string) {
  if (!groupId || groupId <= 0) {
    throw new Error('Invalid Id');
  }

  if (!newGroupName || newGroupName.trim().length === 0) {
    throw new Error('Group name cannot be empty');
  }

  const trimmedName = newGroupName.trim();

  try {

    const predicatesUpdate = new relationalStore.RdbPredicates('groups');
    predicatesUpdate.equalTo('id', groupId);

    const valueBucket: relationalStore.ValuesBucket = {
      'name': trimmedName
    };

    await GlobalRdbStore.rdbStore.update(valueBucket, predicatesUpdate);
  } catch(error) {
    throw new Error(error);
  }
}

export async function deleteGroup(groupId: number) {
  if (!groupId || groupId <= 0) {
    throw new Error('Invalid group ID');
  }

  try {
    const predicates = new relationalStore.RdbPredicates('groups');
    predicates.equalTo('id', groupId);
    await GlobalRdbStore.rdbStore.delete(predicates);
  } catch (error) {
    throw new Error(error);
  }
}

export async function addContactToGroup(contactId: number, groupId: number) {

  if (!contactId || contactId <= 0) {
    throw new Error('Invalid contact ID');
  }
  if (!groupId || groupId <= 0) {
    throw new Error('Invalid group ID');
  }

  try {

    const valueBucket: relationalStore.ValuesBucket = {
      'contact_id': contactId,
      'group_id': groupId
    };

    await GlobalRdbStore.rdbStore.insert('contact_groups', valueBucket);

  } catch (error) {
    const err = error as BusinessError;

    if (err.code === 2067) {
      throw new Error('This contact is already in the group!');
    }

    if (err.code === 2069) {
      throw new Error('Contact or group not found!');
    }

    console.error(`Add contact to group failed, code: ${err.code}, message: ${err.message}`);
    throw new Error(`Failed to add contact to group: ${err.message}`);
  }
}

export async function removeContactFromGroup(contactId: number, groupId: number) {

  if (!contactId || contactId <= 0) {
    throw new Error('Invalid contact ID');
  }
  if (!groupId || groupId <= 0) {
    throw new Error('Invalid group ID');
  }

  try {
    const predicates = new relationalStore.RdbPredicates('contact_groups');
    predicates.equalTo('contact_id', contactId);
    predicates.equalTo('group_id', groupId);

    const affectedRows = await GlobalRdbStore.rdbStore.delete(predicates);

    if (affectedRows === 0) {
      throw new Error('Contact is not in this group!');
    }

  } catch (error) {
    const err = error as BusinessError;
    console.error(`Remove contact from group failed, code: ${err.code}, message: ${err.message}`);
    throw new Error(`Failed to remove contact from group: ${err.message}`);
  }
}

export async function getContactsInGroup(groupId: number): Promise<Contact[]> {
  const contacts: Contact[] = [];
  let resultSet: relationalStore.ResultSet | null = null;

  try {
    const query = `
      SELECT c.*
      FROM contacts c
      INNER JOIN contact_groups cg ON c.id = cg.contact_id
      WHERE cg.group_id = ?
    `;

    resultSet = await GlobalRdbStore.rdbStore.querySql(query, [groupId]) as relationalStore.ResultSet;

    while (resultSet.goToNextRow()) {
      contacts.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        key: resultSet.getString(resultSet.getColumnIndex('key')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        phone: resultSet.getString(resultSet.getColumnIndex('phone'))
      });
    }

    return contacts;

  } catch (error) {
    const err = error as BusinessError;
    console.error(`Get contacts in group failed, code: ${err.code}, message: ${err.message}`);
    throw new Error(`Failed to get contacts in group: ${err.message}`);
  } finally {
    if (resultSet !== null) {
      resultSet.close();
    }
  }
}


