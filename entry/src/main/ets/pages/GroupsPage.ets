import {Group} from '../types/Group';
import {getGroups} from '../utils/GroupsUtils';
import { common} from '@kit.AbilityKit';
import { LengthMetrics } from '@kit.ArkUI';
import { ArcList, ArcListItem, ArcListAttribute, ArcListItemAttribute } from '@kit.ArkUI';
import {router} from '@kit.ArkUI'


@Builder
function buildText() {
  Column() {
    Text('Contacts')
      .fontSize('36px')
      .fontWeight(FontWeight.Bold)
  }
}

@Entry
@Component
export struct GroupsPage {

  @State groups: Group[] = [];
  private watchSize: string = '466px';
  private listSize: string = '410px';

  private navigateToAddGroup() {
    router.pushUrl({
      url: 'pages/AddGroupPage'
    });
  }

  private async loadGroups() {
    try {
      const groups = await getGroups();
      this.groups = groups;
    } catch (error) {
      console.error('Failed to load contacts:', error);
    }
  }

  onPageShow(): void {
    this.loadGroups();
  }

  build() {
    Column() {
      Stack() {
        ArcList({ initialIndex: 0 }) {
          ArcListItem() {
            Button({ type: ButtonType.Capsule }) {
              Row() {
                Text('+ Add Group')
                  .fontSize('24px')
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
            .backgroundColor('#e6f7ff')
            .onClick(() => {
              this.navigateToAddGroup();
            })
          }.align(Alignment.Center)
          ForEach(this.groups, (item: Group) => {
            ArcListItem() {
              Button({ type: ButtonType.Capsule }) {
                Column() {
                  Text(item.name)
                    .fontSize('34px')
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Color.Black)
                    .textAlign(TextAlign.Center)
                    .width('100%')
                    .margin({ bottom: 1 })
                }
                .width('100%')
                .padding(10)
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
            }.align(Alignment.Center)
            .onClick(() => {
              router.push({
                url: 'pages/GroupPage',
                params: item
              });
            })

          }, (group: Group) => group.name)
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
  }
}
