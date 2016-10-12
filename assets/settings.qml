import bb.cascades 1.0
import bb.system 1.0

Page {
    objectName: "Settings Page"
    property bool isCreated
    property string tempPassword
    
    titleBar: TitleBar {
        kind: TitleBarKind.FreeForm
        kindProperties: FreeFormTitleBarKindProperties {
            content: CustomTitleBar {
                titleText: "Settings"
            }
        }
    }
    actions: [
        ActionItem {
            title: "Delete All Files"
            imageSource: "images/delete.png"
            onTriggered: {
                deleteAllDialog.show()
            }  
            ActionBar.placement: ActionBarPlacement.OnBar
        }
    ]

    Container {
        leftPadding: defaultPadding
        rightPadding: defaultPadding
        topPadding: defaultPadding
        bottomPadding: defaultPadding
        layout: DockLayout {
        
        }
        
        attachedObjects: [
        SystemPrompt {
            id: deleteAllDialog
            title: "Delete All Files?"
            inputField.emptyText: "Yes/No"
            body: "Are you use you want to delete all files?"
            onFinished: {
                if (result == SystemUiResult.ConfirmButtonSelection && inputFieldTextEntry().toUpperCase()=="YES") {
                    console.log("Runing Delete Function!")
                    dataSource.execute("DELETE * FROM files;");
                    dataSource.load()
                }
            }
        }
        ]
        onCreationCompleted: {
            isCreated = true
        }
    }
}