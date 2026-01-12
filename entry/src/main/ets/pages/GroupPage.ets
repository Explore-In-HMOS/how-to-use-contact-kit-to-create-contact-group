import { Group } from '../types/Group';
import { BusinessError } from '@kit.BasicServicesKit';
import { Contact } from '../types/Contact';
import { getContacts } from '../utils/ContactUtils';
import { addContactToGroup, removeContactFromGroup, deleteGroup, updateGroup, getContactsInGroup } from '../utils/GroupsUtils';
import common from '@ohos.app.ability.common';
import { promptAction } from '@kit.ArkUI';

@Builder
export function GroupPageBuilder() {
  GroupPage()
}

@Component
export struct GroupPage {
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @State contacts: Contact[] = [];
  @State group: Group | null = null;
  @State showEditPopup: boolean = false;
  @State editName: string = '';
  private groupId: number = -1;
  @State showAddContactPopup: boolean = false;
  @State allContacts: Contact[] = [];
  @State selectedContact: Contact | null = null;
  @Consume pathStack: NavPathStack

  private async loadContacts() {
    try {
      const contacts = await getContactsInGroup(this.groupId);
      this.contacts = contacts;
    } catch (error) {
      console.error('Failed to load contacts:', error);
      promptAction.openToast({
        message: 'Error loading contacts',
        duration: 2000
      });
    }
  }
  private async loadAllContacts() {
    try {
      this.allContacts = await getContacts(this.context as common.UIAbilityContext);
    } catch (error) {
      console.error('Failed to load all contacts:', error);
      promptAction.openToast({
        message: 'Error loading contacts',
        duration: 2000
      });
    }
  }
  onAddContactClick(): void {
    this.showAddContactPopup = true;
    this.loadAllContacts();
    this.selectedContact = null;
  }
  onContactSelect(contact: Contact): void {
    this.selectedContact = contact;
  }
  onAddSelectedContact(): void {
    if (this.selectedContact && this.group) {
      addContactToGroup(this.selectedContact.id, this.group.id)
        .then(() => {
          promptAction.openToast({
            message: `${this.selectedContact?.name} added to group`,
            duration: 2000
          });
          this.showAddContactPopup = false;
          this.selectedContact = null;
          this.loadContacts();
        })
        .catch((error: BusinessError) => {
          promptAction.openToast({
            message: `${error.message}`,
            duration: 3000
          });
        });
    } else {
      promptAction.openToast({
        message: 'Please select a contact',
        duration: 2000
      });
    }
  }
  onCancelAddContact(): void {
    this.showAddContactPopup = false;
    this.selectedContact = null;
  }
  onRemoveContact(contactId: number, contactName: string): void {
    if (this.group) {
      removeContactFromGroup(contactId, this.group!.id)
        .then(() => {
          promptAction.openToast({
            message: `${contactName} removed from group`,
            duration: 2000
          });
          this.loadContacts();
        })
        .catch((error: BusinessError) => {
          promptAction.openToast({
            message: `${error.message}`,
            duration: 3000
          });
        })
    }
  }
  onSaveEdit(): void {
    if (this.group && this.editName.trim()) {
      const updatedGroup: Group = {
        id: this.group.id,
        name: this.editName
      };
      updateGroup(updatedGroup.id, updatedGroup.name)
        .then(() => {
          this.group = updatedGroup;
          this.showEditPopup = false;

          promptAction.openToast({
            message: 'Group updated successfully',
            duration: 2000
          });
        })
        .catch((error: BusinessError) => {
          promptAction.openToast({
            message: `${error.message}`,
            duration: 3000
          });
          console.error('Update error:', error);
        });
    } else {
      promptAction.openToast({
        message: 'Please enter valid name',
        duration: 2000
      });
    }
  }
  onEditClick(): void {
    this.showEditPopup = true;
  }
  onDeleteClick(): void {
    if (this.group) {
      deleteGroup(this.group.id)
        .then(() => {
          promptAction.openToast({
            message: `${this.group?.name} deleted successfully`,
            duration: 2000
          });
          setTimeout(() => {
            this.pathStack.pop()
          }, 1000);
        })
        .catch((error: BusinessError) => {
          promptAction.openToast({
            message: `${error.message}`,
            duration: 3000
          });
          console.error('Delete error:', error);
        });
    }
  }
  onCancelEdit(): void {
    if (this.group) {
      this.editName = this.group.name;
    }
    this.showEditPopup = false;
  }
  build() {
    NavDestination() {
      Stack() {
        Scroll() {
          Column() {
            if (this.group) {
              Column() {
                Text(this.group.name)
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .margin({ bottom: 10 });
              }
              .width('100%')
              .padding(20)
              .justifyContent(FlexAlign.Center)
              Row() {
                Button('Edit')
                  .onClick(() => this.onEditClick())
                  .backgroundColor(Color.Blue)
                  .width(60)
                  .margin({ right: 20 });
                Button('Delete')
                  .onClick(() => this.onDeleteClick())
                  .backgroundColor(Color.Red)
                  .width(60);
              }
              .justifyContent(FlexAlign.Center)
              .width('100%')
              .margin({ bottom: 20 })
              Button('Add Contact to Group')
                .onClick(() => this.onAddContactClick())
                .backgroundColor(Color.Green)
                .width(200)
                .margin({ bottom: 10 })
              if (this.contacts.length > 0) {
                Column() {
                  Text('Contacts in this Group:')
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                    .margin({ bottom: 15 })
                  ForEach(this.contacts, (contact: Contact) => {
                    Row() {
                      Column() {
                        Text(contact.name)
                          .fontSize(16)
                          .fontWeight(FontWeight.Medium)
                          .fontColor(Color.Black)
                        Text(contact.phone)
                          .fontSize(14)
                          .fontColor(Color.Gray)
                      }
                      .layoutWeight(1)

                      Button('Remove')
                        .onClick(() => this.onRemoveContact(contact.id, contact.name))
                        .backgroundColor('#FF3B30')
                        .width(80)
                        .height(30)
                        .fontSize(12)
                    }
                    .width('100%')
                    .padding(15)
                    .margin({ bottom: 10 })
                    .borderRadius(8)
                    .backgroundColor('#F5F5F5')
                  }, (item: Contact) => {
                    return item.id.toString();
                  } )
                }
                .width('100%')
                .padding(20)
              } else {
                Column() {
                  Text('No contacts in this group')
                    .fontSize(16)
                    .fontColor('#666666')
                    .margin({ bottom: 10 })
                  Text('Click Add Contact to get started')
                    .fontSize(14)
                    .fontColor('#999999')
                }
                .width('100%')
                .padding(20)
                .alignItems(HorizontalAlign.Center)
              }
            } else {
              Text('Group not found')
                .fontSize(18)
                .margin({ bottom: 20 });
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%').height('100%')
        if (this.showEditPopup) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#000000')
            .opacity(0.7)
            .onClick(() => this.onCancelEdit())
            .position({ x: 0, y: 0 })
            .zIndex(1)
          Column() {
            TextInput({ text: this.editName })
              .onChange((value: string) => {
                this.editName = value;
              })
              .height(50)
              .width('90%')
              .margin({ bottom: 15 })
              .padding(10)
              .borderRadius(8)
              .borderWidth(1)
              .borderColor('#CCCCCC');
            Row() {
              Button('Cancel')
                .onClick(() => this.onCancelEdit())
                .backgroundColor('#CCCCCC')
                .width(70)
                .margin({ right: 15 });

              Button('Save')
                .onClick(() => this.onSaveEdit())
                .backgroundColor('#007DFF')
                .width(70);
            }
            .justifyContent(FlexAlign.Center).width('100%')
          }
          .width('80%')
          .padding(20)
          .backgroundColor(Color.Black)
          .borderRadius(16)
          .zIndex(2)
          .position({ x: '10%', y: '30%' })
        }
        if (this.showAddContactPopup) {
          Column()
            .width('100%').height('100%')
            .backgroundColor('#000000')
            .opacity(0.7)
            .onClick(() => this.onCancelAddContact())
            .position({ x: 0, y: 0 })
            .zIndex(2)
          Column() {
            if (this.allContacts.length > 0) {
              Scroll() {
                Column() {
                  ForEach(this.allContacts, (contact: Contact) => {
                    Row() {
                      Column() {
                        Text(contact.name)
                          .fontSize(16)
                          .fontWeight(FontWeight.Medium)
                          .fontColor(Color.Black)
                        Text(contact.phone)
                          .fontSize(14)
                          .fontColor('#666666')
                      }
                      .layoutWeight(1)
                    }
                    .width('100%')
                    .padding(15)
                    .margin({ bottom: 8 })
                    .borderRadius(8)
                    .backgroundColor(this.selectedContact?.id === contact.id ? '#E3F2FD' : '#FFFFFF')
                    .onClick(() => this.onContactSelect(contact))
                  }, (item: Contact) => {
                    return item.id.toString();
                  })
                }
              }
              .height(300).width('100%').margin({ bottom: 10 })
            } else {
              Text('No contacts available')
                .fontSize(16)
                .fontColor('#666666')
                .margin({ bottom: 20 })
            }
            Row() {
              Button('Cancel')
                .onClick(() => this.onCancelAddContact())
                .backgroundColor('#CCCCCC')
                .width(100)
                .margin({ right: 15 })
              Button('Add')
                .onClick(() => this.onAddSelectedContact())
                .backgroundColor('#34C759')
                .width(100)
                .enabled(!!this.selectedContact)
            }
            .justifyContent(FlexAlign.Center)
            .width('100%')
          }
          .width('90%').height('70%')
          .padding(20)
          .backgroundColor(Color.Black)
          .borderRadius(16)
          .zIndex(3)
          .position({ x: '5%', y: '15%' })
        }
      }
      .width('100%').height('100%')
    }.onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
      const params = context.pathInfo.param as Group
      if (params) {
        this.group = {
          id: params.id,
          name: params.name
        }
        this.editName = params.name;
        this.groupId = params.id;
        this.loadContacts();
      }
    })
    .hideTitleBar(true)

  }
}