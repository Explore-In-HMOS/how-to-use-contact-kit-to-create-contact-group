import {mainMenuItems} from '../viewmodel/MainMenuItems';
import {MainMenuItem} from '../types/MainMenuItem';
import { ArcList, ArcListItem, ArcListAttribute, ArcListItemAttribute, ComponentContent, LengthMetrics, promptAction, UIContext } from '@kit.ArkUI';
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Builder
function buildText() {
  Text('Contact Groups')
    .fontSize('36px')
    .fontWeight(FontWeight.Bold)
}

@Entry
@Component
struct Index {

  @Provide pathStack: NavPathStack = new NavPathStack()
  @State mainMenuItems: MainMenuItem[] = mainMenuItems
  private watchSize: string = '466px'
  private listSize: string = '410px'
  private context2 = this.getUIContext().getHostContext() as common.UIAbilityContext;
  context: UIContext = this.getUIContext()
  tabBar1: ComponentContent<Object> = new ComponentContent(this.context, wrapBuilder(buildText));

  private readonly writePermissions: Array<Permissions> = ['ohos.permission.WRITE_CONTACTS'];
  private readonly readPermissions: Array<Permissions> = ['ohos.permission.READ_CONTACTS'];

  private async checkWritePermissions(): Promise<boolean> {
    try {
      const result = await abilityAccessCtrl.createAtManager()
        .requestPermissionsFromUser(this.context2, this.writePermissions);
      return result.authResults[0] === 0;
    } catch (err) {
      console.error('Permission Error:', (err as BusinessError).code);
      promptAction.openToast({
        message: 'Permission Error: ' + (err as BusinessError).code,
        duration: 3000
      });
      return false;
    }
  }

  private async checkReadPermissions(): Promise<boolean> {
    try {
      const result = await abilityAccessCtrl.createAtManager()
        .requestPermissionsFromUser(this.context2, this.readPermissions);
      return result.authResults[0] === 0;
    } catch (err) {
      console.error('Permission Error:', (err as BusinessError).code);
      promptAction.openToast({
        message: 'Permission Error: ' + (err as BusinessError).code,
        duration: 3000
      });
      return false;
    }
  }

  aboutToAppear(): void {
    this.checkWritePermissions();
    this.checkReadPermissions();
  }

  build() {
    Navigation() {
      Column() {
        Stack() {
          ArcList({ initialIndex: 0, header: this.tabBar1 }) {
            ForEach(this.mainMenuItems, (item: MainMenuItem) => {
              ArcListItem() {
                Button({ type: ButtonType.Capsule }) {
                  Row() {
                    Image(item.icon)
                      .width('64px')
                      .height('64px')
                      .margin({ right: '12px' })
                    Text(`${item.name}`)
                      .fontSize('36px')
                      .fontColor(Color.Black)
                      .fontWeight(FontWeight.Bold)
                  }
                  .justifyContent(FlexAlign.Center)
                  .width('100%')
                }
                .width(this.listSize)
                .height('100px')
                .fontSize('24px')
                .fontColor(Color.Black)
                .fontWeight(FontWeight.Bold)
                .focusable(true)
                .opacity(0.9)
                .focusOnTouch(true)
                .backgroundColor('#f0f8ff')
              }.align(Alignment.Center).onClick(() => {
                this.pathStack.pushPathByName(`${item.pageName}`,null)
              })

            }, (item: string, index: number) => item)
          }
          .space(LengthMetrics.px(10))
          .borderRadius(this.watchSize)
          .focusable(true)
          .focusOnTouch(true)
          .defaultFocus(true)
        }
        .align(Alignment.Center)
        .width(this.watchSize)
        .height(this.watchSize)
        .border({color: Color.Black, width: 3})
        .borderRadius(this.watchSize)
      }
      .height('100%')
      .width('100%')
    }.mode(NavigationMode.Stack).hideTitleBar(true)
  }
}