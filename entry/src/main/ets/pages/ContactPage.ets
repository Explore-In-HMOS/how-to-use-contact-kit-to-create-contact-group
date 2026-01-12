import { Contact } from '../types/Contact';
import { deleteContact, updateContact } from '../utils/ContactUtils';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';

@Builder
export function ContactPageBuilder() {
  ContactPage()
}

@Entry
@Component
struct ContactPage {
  @State contact: Contact | null = null;
  @State showEditPopup: boolean = false;
  @State editName: string = '';
  @State editPhone: string = '';
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @Consume pathStack: NavPathStack

  onEditClick(): void {
    this.showEditPopup = true;
  }

  onSaveEdit(): void {
    if (this.contact && this.editName.trim() && this.editPhone.trim()) {
      const updatedContact: Contact = {
        id: this.contact.id,
        key: this.contact.key,
        name: this.editName,
        phone: this.editPhone
      };

      updateContact(this.context, updatedContact.id, updatedContact.name, updatedContact.phone)
        .then(() => {
          this.contact = updatedContact;
          this.showEditPopup = false;

          promptAction.openToast({
            message: 'Contact updated successfully',
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
        message: 'Please enter valid name and phone number',
        duration: 2000
      });
    }
  }

  onDeleteClick(): void {
    if (this.contact) {
      deleteContact(this.context, this.contact.key)
        .then(() => {
          promptAction.openToast({
            message: `${this.contact?.name} deleted successfully`,
            duration: 2000
          });
          setTimeout(() => {
            this.pathStack.pop();
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
    if (this.contact) {
      this.editName = this.contact.name;
      this.editPhone = this.contact.phone;
    }
    this.showEditPopup = false;
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          if (this.contact) {
            Column() {
              Text(this.contact.name)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 10 });

              Text(this.contact.phone)
                .fontSize(18)
                .margin({ bottom: 10 });
            }
            .width('100%')
            .padding(20)
            .justifyContent(FlexAlign.Center)

            Row() {
              Button('Edit')
                .onClick(() => this.onEditClick())
                .backgroundColor('#007DFF')
                .width(60)
                .margin({ right: 20 });

              Button('Delete')
                .onClick(() => this.onDeleteClick())
                .backgroundColor('#FF3B30')
                .width(60);
            }
            .justifyContent(FlexAlign.Center)
            .width('100%')
          } else {
            Text('Contact not found')
              .fontSize(18)
              .margin({ bottom: 20 });
          }
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        if (this.showEditPopup) {

          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#000000')
            .opacity(0.9)
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

            TextInput({ text: this.editPhone })
              .onChange((value: string) => {
                this.editPhone = value;
              })
              .height(50)
              .width('90%')
              .margin({ bottom: 10 })
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
            .justifyContent(FlexAlign.Center)
            .width('100%')
          }
          .width('100%')
          .padding(20)
          .alignItems(HorizontalAlign.Center)
          .borderRadius(16)
          .zIndex(1)
        }
      }
      .width('100%')
      .height('100%')
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
      const params = context.pathInfo.param as Contact
      if (params) {
        this.contact = {
          id: params.id,
          key: params.key,
          name: params.name,
          phone: params.phone
        }
        this.editName = params.name;
        this.editPhone = params.phone;
      }
    })
    .hideTitleBar(true)
  }
}