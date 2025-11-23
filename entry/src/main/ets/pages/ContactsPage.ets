import {Contact} from '../types/Contact';
import {getContacts} from '../utils/ContactUtils';
import { common} from '@kit.AbilityKit';
import { ArcList, ArcListItem, ArcListAttribute, ArcListItemAttribute, LengthMetrics } from '@kit.ArkUI';

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
struct ContactsPage {
  @State contacts: Contact[] = [];
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  private watchSize: string = '466px';
  private listSize: string = '410px';

  private navigateToAddContact() {
    this.getUIContext().getRouter().pushUrl({
      url: 'pages/AddContactPage'
    });
  }

  private async loadContacts() {
    try {
      const contacts = await getContacts(this.context);
      this.contacts = contacts;
    } catch (error) {
      console.error('Failed to load contacts:', error);
    }
  }

  onPageShow(): void {
    this.loadContacts();
  }

  build() {
    Column() {
      Stack() {
        ArcList({ initialIndex: 0 }) {
          ArcListItem() {
            Button({ type: ButtonType.Capsule }) {
              Row() {
                Text('+ Add Contact')
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
              this.navigateToAddContact();
            })
          }.align(Alignment.Center)
          ForEach(this.contacts, (item: Contact) => {
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
              this.getUIContext().getRouter().pushUrl({
                url: 'pages/ContactPage',
                params: item
              });
            })

          }, (contact: Contact) => contact.name)
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