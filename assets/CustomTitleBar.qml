import bb.cascades 1.0

Container {
    property string titleText
    layout: DockLayout {

    }
    horizontalAlignment: HorizontalAlignment.Fill
    ImageView {
        imageSource: "asset:///images/metalTitleBg.png"
        horizontalAlignment: HorizontalAlignment.Fill
    }
    Container {
        layout: DockLayout {

        }
        horizontalAlignment: HorizontalAlignment.Fill

        rightPadding: 21
        topPadding: 21
        leftPadding: 21
        bottomPadding: 21

        Label {
            text: titleText
            verticalAlignment: VerticalAlignment.Center
            textStyle {
                base: SystemDefaults.TextStyles.TitleText
            }
        }
        ImageView {
            imageSource: "asset:///images/keyhole.png"
            preferredHeight: 81
            horizontalAlignment: HorizontalAlignment.Right
            verticalAlignment: VerticalAlignment.Center
            scalingMethod: ScalingMethod.AspectFit
        }
    }
}
