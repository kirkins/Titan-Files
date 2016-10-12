import bb.cascades 1.0

Dialog {
    onOpened: {
        console.log("PROCESSING DIALOG OPENED")
    }
    onClosed: {
        console.log("PROCESSING DIALOG CLOSED")
    }
    Container {
        preferredWidth: displayWidth
        preferredHeight: displayHeight

        background: Color.create(0.0, 0.0, 0.0, 0.5)

        layout: DockLayout {
        }

        Container {
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            layout: StackLayout {
                
            }
            
            ActivityIndicator {
                horizontalAlignment: HorizontalAlignment.Center
                preferredWidth: 184
                running: true
            }
            Label {
                text: processingMessage
                horizontalAlignment: HorizontalAlignment.Center
                textStyle.textAlign: TextAlign.Center
                multiline: true
            }
        }
    }
}