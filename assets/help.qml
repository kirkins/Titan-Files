import bb.cascades 1.0

Page {
    objectName: "Help Page"
    property alias dropDown: dropDown
    
    titleBar: TitleBar {
        kind: TitleBarKind.FreeForm
        kindProperties: FreeFormTitleBarKindProperties {
            content: CustomTitleBar {
                titleText: "About"
            }
        }
    }
    Container {
        layout: DockLayout {
        }
        Container {
            leftPadding: defaultPadding
            rightPadding: defaultPadding
            topPadding: defaultPadding
            DropDown {
                id: dropDown
                title: "Subject"
                selectedIndex: 0
                Option {
                    text: "What is Titan Files"
                    value: "Titan Files is the most secure way to store files on your phone. Titan Files uses AES encryption which has been approved to protect classified information up to the Top Secret level."
                }
                Option {
                    text: "About Pivot Point"
                    value: "Our mission is to make useful apps for a new era of BlackBerry 10 users. Armed with the premise that BlackBerry 10 users need solution oriented tools to balance the needs of their work and personal life to help them be more productive and protected, we strive to create apps that harness and unleash the magic of BlackBerry 10 devices." +
                    "\n\nAll of our apps are exclusively available through BlackBerry World."
                }
                Option {
                    text: "About Granite Apps"
                    value: "Granite Applicaitons is a custom software development agency, specializing in mobile. We work with clients like Pivot Point to bring security and business solutions to the BlackBerry platform." +
                    "\n\nTaylor Brynes - Security & Encryption" +
                    "\n\nqbo - Design & UX" +
                    "\n\nPhilip Kirkbride - Project Manager" +
                    "\n\nMuraknockout Media - Font Design"
                }
                Option {
                    text: "Privacy Policy"
                    value: "The Titan Files app for BlackBerry 10 securely stores your files on your BlackBerry device. Your stored files are never sent anywhere outside of your phone, in order to ensure maximum security."
                }
                Option {
                    text: "About AES Encryption"
                    value: "Until May 2009, the only successful published attacks against the full AES were side-channel attacks on some specific implementations. The National Security Agency (NSA) reviewed all the AES finalists, including Rijndael, and stated that all of them were secure enough for U.S. Government non-classified data. In June 2003, the U.S. Government announced that AES could be used to protect classified information" +
                    "\n\nThe design and strength of all key lengths of the AES algorithm (i.e., 128, 192 and 256) are sufficient to protect classified information up to the SECRET level. TOP SECRET information will require use of either the 192 or 256 key lengths. The implementation of AES in products intended to protect national security systems and/or information must be reviewed and certified by NSA prior to their acquisition and use."
                }
            }
            ScrollView {
                verticalAlignment: VerticalAlignment.Fill
                horizontalAlignment: HorizontalAlignment.Fill
                Container {
                    horizontalAlignment: HorizontalAlignment.Fill
                    Label {
                        text: dropDown.selectedOption.text
                        multiline: true
                        textStyle {
                            base: SystemDefaults.TextStyles.BigText
                            color: Color.create("#82b83a")
                        }
                    }
                    Label {
                        text: dropDown.selectedValue
                        multiline: true
                    }
                }
            }
        }
    }
    actions: [
        ActionItem {
            title: "Support"
            imageSource: "asset:///images/email.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                invokeEmail.trigger("bb.action.SENDEMAIL")
            }
        },
        //        ActionItem {
        //            title: "Report Bug"
        //            imageSource: "asset:///images/email.png"
        //            ActionBar.placement: ActionBarPlacement.OnBar
        //            onTriggered: {
        //                invokeEmail.trigger("bb.action.SENDEMAIL")
        //            }
        //        },
        //        ActionItem {
        //            title: "Leave Feedback"
        //            imageSource: "asset:///images/appworld.png"
        //            ActionBar.placement: ActionBarPlacement.InOverflow
        //            onTriggered: {
        //                invokeAppWorld.trigger("bb.action.OPEN")
        //            }
        //        },
        //        ActionItem {
        //            title: "Invite to Download"
        //            imageSource: "asset:///images/bbm.png"
        //            ActionBar.placement: ActionBarPlacement.InOverflow
        //            onTriggered: {
        //                inviteToDownload.sendInvite();
        //            }
        //        },
        ActionItem {
            title: "Follow Us"
            imageSource: "asset:///images/snsTwitter.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                invokeTwitter.trigger("bb.action.OPEN")
            }
        },
        ActionItem {
            title: "Like Us"
            imageSource: "asset:///images/snsFacebook.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                invokeFacebook.trigger("bb.action.OPEN")
            }
        }
    ]
    attachedObjects: [
        Invocation {
            id: invokeEmail
            query {
                mimeType: "text/html"
                invokeTargetId: "sys.pim.uib.email.hybridcomposer"
                invokeActionId: "bb.action.SENDEMAIL"
                uri: "mailto:bob@pivotpointresearch.com?subject=Bug%20Report"
            }
        },
        Invocation {
            id: invokeAppWorld
            query {
                mimeType: "text/html"
                //uri: "appworld://content/29398905"
                invokeActionId: "bb.action.OPEN"
            }
        },
        Invocation {
            id: invokeTwitter
            query {
                mimeType: "text/html"
                uri: "https://twitter.com/PivotPointSG"
                invokeActionId: "bb.action.OPEN"
            }
        },
        Invocation {
            id: invokeFacebook
            query {
                mimeType: "text/html"
                uri: "https://www.facebook.com/pages/Pivot-Point-Solution"
                invokeActionId: "bb.action.OPEN"
            }
        }
    ]
}
