import { addGroup } from '../utils/GroupsUtils';
import { prompt, promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
export struct AddGroupPage {
  @State name: string = '';

  private async saveGroup() {
    if (!this.name.trim()){
      promptAction.showToast({ message: 'Please fill all fields' });
      return;
    }

    try {
      await addGroup(this.name).then(() => {
        prompt.showToast({
          message: `${this.name} added successfully`,
          duration: 2000
        });
        setTimeout(() => {
          this.getUIContext().getRouter().back();
        }, 1000);
      })
        .catch((error: BusinessError) => {
          prompt.showToast({
            message: 'Error adding group: ' + error.message,
            duration: 3000
          });
          console.error('Adding error:', error);
        });
    } catch (error) {
      promptAction.showToast({ message: 'Group Adding Error!' });
    }
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          TextInput({ placeholder: 'Group Name' })
            .width('70%')
            .height(50)
            .fontSize(18)
            .margin({ top: 40, bottom: 10 })
            .padding(10)
            .border({ width: 1, color: Color.White, radius: 15 })
            .onChange((value: string) => {
              this.name = value;
            })

          Button('Save')
            .width('70%')
            .height(50)
            .fontSize(18)
            .backgroundColor(this.name ? '#007AFF' : '#ccc')
            .enabled(!!this.name)
            .onClick(() => {
              this.saveGroup();
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