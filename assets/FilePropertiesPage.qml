import bb.cascades 1.0

Page {
    property string fileName
    //    property alias reConstructDataModel: reConstructDataModel
    //    property string fileType
    //    property string fileModifiedDate
    //    property string fileSize
    //    property alias fileName: titleBar.title
    //    property alias fileType: fileTypeLabel.text
    //    property alias fileModifiedDate: fileModifiedDateLabel.text
    //    property alias fileSize: fileSizeLabel.text

    titleBar: TitleBar {
        title: fileName
    }
    ListView {
        dataModel: groupDataModel
        listItemComponents: [
            ListItemComponent {
                type: "header"

                Header {
                    title: ListItemData
                }
            },

            ListItemComponent {
                type: "item"

                StandardListItem {
                    title: ListItemData.val
                }
            }
        ]
    }
    attachedObjects: [
        GroupDataModel {
            id: groupDataModel
            sortingKeys: [ "label", "val" ]
            grouping: ItemGrouping.ByFullValue
        }
    ]
    function constructDataModel(fileType, fileModifiedDate, fileSize) {
        groupDataModel.clear()
        groupDataModel.insert({
                "label": "File Type",
                "val": fileType.toUpperCase()
            })
        groupDataModel.insert({
                "label": "Modified Date",
                "val": Qt.formatDate(new Date(fileModifiedDate.split("-")[0],fileModifiedDate.split("-")[1] - 1,fileModifiedDate.split("-")[2]), "MMMM dd, yyyy")
            })
        groupDataModel.insert({
                "label": "File Size",
                "val": parseInt(fileSize) > 999999 ? parseInt(fileSize) / 1000000 + " MB" : parseInt(fileSize) > 999 ? parseInt(fileSize) / 1000 + " KB" : parseInt(fileSize) + " B"
            })
    }
}
