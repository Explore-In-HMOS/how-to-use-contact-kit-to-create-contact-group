import { Contact } from '../types/Contact';
import router from '@ohos.router';
import { deleteContact, updateContact } from '../utils/ContactUtils';
import { common } from '@kit.AbilityKit';
import prompt from '@ohos.prompt';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct ContactPage {
  @State contact: Contact | null = null;
  @State showEditPopup: boolean = false;
  @State editName: string = '';
  @State editPhone: string = '';
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToAppear(): void {
    const params = router.getParams() as Contact;
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
  }

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

          prompt.showToast({
            message: 'Contact updated successfully',
            duration: 2000
          });
        })
        .catch((error: BusinessError) => {
          prompt.showToast({
            message: 'Error updating contact: ' + error.message,
            duration: 3000
          });
          console.error('Update error:', error);
        });
    } else {
      prompt.showToast({
        message: 'Please enter valid name and phone number',
        duration: 2000
      });
    }
  }

  onDeleteClick(): void {
    prompt.showDialog({
      title: 'Delete Contact',
      message: `Are you sure you want to delete ${this.contact?.name}?`,
      buttons: [
        {
          text: 'No',
          color: '#000000'
        },
        {
          text: 'Yes',
          color: '#FF3B30'
        }
      ]
    }).then((data) => {
      if (data.index === 1) {
        if (this.contact) {
          deleteContact(this.context, this.contact.key)
            .then(() => {
              prompt.showToast({
                message: `${this.contact?.name} deleted successfully`,
                duration: 2000
              });
              setTimeout(() => {
                router.back();
              }, 1000);
            })
            .catch((error: BusinessError) => {
              prompt.showToast({
                message: 'Error deleting contact: ' + error.message,
                duration: 3000
              });
              console.error('Delete error:', error);
            });
        }
      }
    });
  }

  onCancelEdit(): void {
    if (this.contact) {
      this.editName = this.contact.name;
      this.editPhone = this.contact.phone;
    }
    this.showEditPopup = false;
  }

  build() {
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
}