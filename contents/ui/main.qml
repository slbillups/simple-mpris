import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.private.mpris as Mpris
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: root
    
    //widget opacity
    property real widgetOpacity: 1.0  // Initial opacity is 100%
    readonly property real minOpacity: 0.1  // Minimum opacity (10%)
    readonly property real opacityStep: 0.04 // Change by 4% per scroll
    //seek & volume 
    property bool isSeeking: false
    property int seekHideDelay: 1500
    property string currentVolumeText: ""
    //background transparency
    readonly property bool transparentBackgroundEnabled: Plasmoid.configuration.transparentBackgroundEnabled
    Plasmoid.backgroundHints: transparentBackgroundEnabled

    readonly property int defaultPixelSize: 12
    readonly property int defaultMultiplier: 1
    readonly property bool defaultBold: false 
    readonly property bool defaultItalic: false
    readonly property bool defaultUnderline: false
    readonly property int defaultAlignment: Text.AlignHCenter

    // Configuration property getters with fallbacks
    readonly property int timeOverlayPixelSize: plasmoid?.configuration?.timeOverlayPixelSize ?? defaultPixelSize
    readonly property int volumeOverlayPixelSize: plasmoid?.configuration?.volumeOverlayPixelSize ?? defaultPixelSize
    readonly property int timeOverlayAlignment: plasmoid?.configuration?.timeOverlayAlignment ?? defaultAlignment
    readonly property int volumeOverlayAlignment: plasmoid?.configuration?.volumeOverlayAlignment ?? defaultAlignment
    readonly property bool timeTextBold: plasmoid?.configuration?.timeTextBold ?? defaultBold
    readonly property bool timeTextItalic: plasmoid?.configuration?.timeTextItalic ?? defaultItalic
    readonly property bool timeTextUnderline: plasmoid?.configuration?.timeTextUnderline ?? defaultUnderline
    readonly property bool volumeTextBold: plasmoid?.configuration?.volumeTextBold ?? defaultBold
    readonly property bool volumeTextItalic: plasmoid?.configuration?.volumeTextItalic ?? defaultItalic
    readonly property bool volumeTextUnderline: plasmoid?.configuration?.volumeTextUnderline ?? defaultUnderline

    width: Kirigami.Units.gridUnit * 12
    height: width

    readonly property int volumePercentStep: 5
    property var mediaController: mpris2Model.currentPlayer

    readonly property var track: mpris2Model.currentPlayer?.track ?? plasmoid.configuration.track
    readonly property var artist: mpris2Model.currentPlayer?.artist ?? plasmoid.configuration.artist
    readonly property var albumArt: mpris2Model.currentPlayer?.artUrl ?? ""
    readonly property bool isPlaying: mpris2Model.currentPlayer?.playbackStatus === Mpris.PlaybackStatus.Playing
    readonly property bool canSeek: mpris2Model.currentPlayer?.canSeek ?? false
    readonly property double position: mpris2Model.currentPlayer?.position ?? 0
    readonly property double duration: mpris2Model.currentPlayer?.length ?? 0  // Use length instead of metadata.duration
    readonly property int length: mpris2Model.currentPlayer ? mpris2Model.currentPlayer.length : 0

    function seek(offset) {
        if (canSeek && mpris2Model.currentPlayer) {
            mpris2Model.currentPlayer.Seek(offset);
            root.isSeeking = true;
            seekOverlayTimer.restart();
            console.log(`Seeking by offset: ${offset}ms`);
        }
    }

    function adjustSystemVolume(delta) {
        if (mpris2Model.currentPlayer) {
            const currentVolume = mpris2Model.currentPlayer.volume || 0;
            const newVolume = Math.max(0, Math.min(1, currentVolume + (delta / 100)));
            mpris2Model.currentPlayer.volume = newVolume;

            // Update volume overlay text
            volumeOverlay.text = Math.round(newVolume * 100) + "%";
            volumeOverlay.opacity = 1;
            overlayTimer.restart();

            console.log(`Volume adjusted to: ${Math.round(newVolume * 100)}%`);
        }
    }

    function togglePlaying() {
        if (root.isPlaying) {
            mpris2Model.currentPlayer.Pause();
        } else {
            mpris2Model.currentPlayer.Play();
        }
    }

    Mpris.Mpris2Model {
        id: mpris2Model
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing
        opacity: root.widgetOpacity // Add this line

        // Add smooth animation
        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }
        }

        Item {
            id: albumArtContainer
            Layout.fillWidth: true
            Layout.preferredHeight: width

            Image {
                id: albumArtImage
                source: root.albumArt.length > 0 ? root.albumArt : "[mpris:artUrl]"
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
            }

            Text {
                id: volumeOverlay
                anchors {
                    left: root.volumeOverlayAlignment === Text.AlignLeft ? albumArtContainer.left : undefined
                    right: root.volumeOverlayAlignment === Text.AlignRight ? albumArtContainer.right : undefined
                    horizontalCenter: root.volumeOverlayAlignment === Text.AlignHCenter ? albumArtContainer.horizontalCenter : undefined
                    top: parent.top
                    bottomMargin: Kirigami.Units.largeSpacing
                }
                horizontalAlignment: root.volumeOverlayAlignment
                text: ""
                color: "white"
                font {
                    pixelSize: root.volumeOverlayPixelSize * root.defaultMultiplier
                    bold: root.volumeTextBold
                    italic: root.volumeTextItalic
                    underline: root.volumeTextUnderline
                }
                opacity: text.length > 0 ? 1 : 0
                visible: opacity > 0
                z: 1
                style: Text.Outline
                styleColor: "black"

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            Text {
                id: timeOverlay
                anchors {
                    left: root.timeOverlayAlignment === Text.AlignLeft ? albumArtContainer.left : undefined
                    right: root.timeOverlayAlignment === Text.AlignRight ? albumArtContainer.right : undefined
                    horizontalCenter: root.timeOverlayAlignment === Text.AlignHCenter ? albumArtContainer.horizontalCenter : undefined
                    bottom: parent.bottom
                    bottomMargin: Kirigami.Units.largeSpacing
                }
                horizontalAlignment: root.timeOverlayAlignment
                text: {
                    const pos = Math.floor(root.position / 1000000);  // Convert microseconds to seconds
                    const len = Math.floor(root.length / 1000000);    // Convert microseconds to seconds
                    const posStr = formatSeconds(pos);
                    const lenStr = formatSeconds(len);
                    return `${posStr}/${lenStr}`;
                }
                color: "white"
                font {
                    pixelSize: root.timeOverlayPixelSize * root.defaultMultiplier
                    bold: root.timeTextBold
                    italic: root.timeTextItalic
                    underline: root.timeTextUnderline
                }
                opacity: root.isSeeking ? 1 : 0
                visible: opacity > 0
                z: 1
                style: Text.Outline
                styleColor: "black"

                Component.onCompleted: {
                    console.log("TimeOverlay completed")
                    console.log("Configuration available:", plasmoid?.configuration !== undefined)
                    console.log("Using pixel size:", font.pixelSize)
                }

                function formatSeconds(secs) {
                    const minutes = Math.floor(secs / 60);
                    const seconds = Math.floor(secs % 60);
                    return `${minutes}:${seconds.toString().padStart(2, '0')}`;
                    
                }
            }

            Rectangle {
                id: seekBar
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: parent.height * 0.015
                z: 400

                Rectangle {
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    width: parent.width * (root.position / Math.max(1000000, root.duration))
                    color: "white"
                }
                color: "#4D000000"  // Semi-transparent black
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.margins: Kirigami.Units.smallSpacing
            spacing: 0

            PC3.Label {
                id: songTitle
                Layout.fillWidth: true
                text: root.track
                font.pointSize: Kirigami.Theme.defaultFont.pointSize
                font.weight: Font.Medium
                horizontalAlignment: Text.AlignHCenter
                color: Kirigami.Theme.textColor
                elide: Text.ElideRight
                maximumLineCount: 1
                wrapMode: Text.NoWrap
                opacity: root.isPlaying ? 1.0 : 0.6

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }
            }

            PC3.Label {
                id: songArtist
                Layout.fillWidth: true
                text: root.artist
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                horizontalAlignment: Text.AlignHCenter
                color: Kirigami.Theme.textColor
                opacity: 0.6
                elide: Text.ElideRight
                maximumLineCount: 1
                wrapMode: Text.NoWrap
                visible: text.length > 0
            }
        }
    }

    Timer {
        id: overlayTimer
        interval: 1500
        onTriggered: volumeOverlay.opacity = 0
    }

    Timer {
        id: seekOverlayTimer
        interval: seekHideDelay
        onTriggered: root.isSeeking = false
    }

    Timer {
    id: seekTimer
    interval: 1000 / (mpris2Model.currentPlayer?.rate ?? 1)
    repeat: true
    running: root.isPlaying
    onTriggered: {
        if (!root.isSeeking) {
            mpris2Model.currentPlayer?.updatePosition()
        }
    }
}

    Connections {
        target: Plasmoid
        function onFormFactorChanged() {
            albumArtContainer.Layout.preferredHeight = width;
            
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton // Don't handle clicks
        onWheel: {
            // delta is positive when scrolling up, negative when scrolling down
            if (wheel.angleDelta.y > 0) {
                // Scrolling up - increase opacity
                widgetOpacity = Math.min(1.0, widgetOpacity + opacityStep)
            } else {
                // Scrolling down - decrease opacity
                widgetOpacity = Math.max(minOpacity, widgetOpacity - opacityStep)
            }
            console.log("Widget opacity: " + (widgetOpacity * 100) + "%")
        }
    }

    Item {
        focus: true
        Keys.onPressed: function(event) {
            if (root.isConfigOpen) {
                // Ignore key events while the config dialog is open
                return;
            }

            switch (event.key) {
                case Qt.Key_Space:
                    togglePlaying();
                    event.accepted = true;
                    console.log("Space pressed - toggling playback");
                    break;
                case Qt.Key_Left:
                    if (event.modifiers & Qt.ControlModifier) {
                        if (mpris2Model.currentPlayer.canGoPrevious) {
                            mpris2Model.currentPlayer.Previous();
                            console.log("Ctrl+Left pressed - previous song");
                        }
                    } else {
                        seek(-5000000); // Seek backward 5 seconds
                        console.log("Left arrow pressed - seeking back");
                    }
                    event.accepted = true;
                    break;
                case Qt.Key_Right:
                    if (event.modifiers & Qt.ControlModifier) {
                        if (mpris2Model.currentPlayer.canGoNext) {
                            mpris2Model.currentPlayer.Next();
                            console.log("Ctrl+Right pressed - next song");
                        }
                    } else {
                        seek(5000000); // Seek forward 5 seconds
                        console.log("Right arrow pressed - seeking forward");
                    }
                    event.accepted = true;
                    break;
                case Qt.Key_Up:
                    adjustSystemVolume(5); // Increase system volume by 1%
                    event.accepted = true;
                    console.log("Plus key pressed - increasing system volume");
                    break;
                case Qt.Key_Down:
                    adjustSystemVolume(-5); // Decrease system volume by 1%
                    event.accepted = true;
                    console.log("Minus key pressed - decreasing system volume");
                    break;
            }
        }
    }
}
