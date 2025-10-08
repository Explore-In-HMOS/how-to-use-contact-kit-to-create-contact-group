import { addContact } from '../utils/ContactUtils';
import { common } from '@kit.AbilityKit';
import { prompt, router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct AddContactPage {
  @State name: string = '';
  @State phoneNumber: string = '';

  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  private async saveContact() {
    if (!this.name.trim() || !this.phoneNumber.trim()) {
      promptAction.showToast({ message: 'Please fill all fields' });
      return;
    }

    try {
      await addContact(this.context, this.name, this.phoneNumber).then(() => {
        prompt.showToast({
          message: `${this.name} added successfully`,
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
          console.error('Adding error:', error);
        });
    } catch (error) {
      promptAction.showToast({ message: 'Contact Adding Error!' });
    }
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          TextInput({ placeholder: 'Full Name' })
            .width('70%')
            .height(50)
            .fontSize(18)
            .margin({ top: 40, bottom: 10 })
            .padding(10)
            .border({ width: 1, color: Color.White, radius: 15 })
            .onChange((value: string) => {
              this.name = value;
            })

          TextInput({ placeholder: 'Phone Number' })
            .width('70%')
            .height(50)
            .fontSize(18)
            .margin({ bottom: 10 })
            .padding(10)
            .type(InputType.PhoneNumber)
            .border({ width: 1, color: Color.White, radius: 15 })
            .onChange((value: string) => {
              this.phoneNumber = value;
            })

          Button('Save')
            .width('70%')
            .height(50)
            .fontSize(18)
            .backgroundColor(this.name && this.phoneNumber ? '#007AFF' : '#ccc')
            .enabled(!!this.name && !!this.phoneNumber)
            .onClick(() => {
              this.saveContact();
            })
            .margin({ bottom: 20 })

        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}