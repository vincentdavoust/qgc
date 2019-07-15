/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


/**
 * @file
 *   @brief QGC Compass Widget
 *   @author Gus Grubba <mavlink@grubba.com>
 */

import QtQuick              2.3
import QtGraphicalEffects   1.0

import QGroundControl              1.0
import QGroundControl.Controls     1.0
import QGroundControl.ScreenTools  1.0
import QGroundControl.Vehicle      1.0
import QGroundControl.Palette      1.0

Item {
    id:     root
    width:  size
    height: size

    property real size:     _defaultSize
    property var  vehicle:  null

    property real _defaultSize:     ScreenTools.defaultFontPixelHeight * (10)
    property real _sizeRatio:       ScreenTools.isTinyScreen ? (size / _defaultSize) * 0.5 : size / _defaultSize
    property int  _fontSize:        ScreenTools.defaultFontPointSize * _sizeRatio
    property real _heading:         vehicle ? vehicle.heading.rawValue : 0
    property real _headingToHome:   vehicle ? vehicle.headingToHome.rawValue : 0
    property real _courseOverGround:activeVehicle ? activeVehicle.gps.courseOverGround.rawValue : 0

    readonly property bool _showHomeHeadingCompass:        QGroundControl.settingsManager.flyViewSettings.showHomeHeadingCompass.value
    readonly property bool _showCOGAngleCompass:        QGroundControl.settingsManager.flyViewSettings.showCOGAngleCompass.value

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }


    Rectangle {
        id:             borderRect
        anchors.fill:   parent
        radius:         width / 2
        color:          qgcPal.window
        border.color:   qgcPal.text
        border.width:   1
    }

    Item {
        id:             instrument
        anchors.fill:   parent
        visible:        false

        Image {
            id:                 cOGPointer
            source:             _showCOGAngleCompass ? "/qmlimages/cOGPointer.svg" : ""
            mipmap:             true
            fillMode:           Image.PreserveAspectFit
            anchors.fill:       parent
            sourceSize.height:  parent.height

            transform: Rotation {
                origin.x:       cOGPointer.width  / 2
                origin.y:       cOGPointer.height / 2
                angle:         _courseOverGround - _heading
            }
        }

        Image {
            id:                 pointer
            width:              size * 0.65
            source:             vehicle ? vehicle.vehicleImageCompass : ""
            mipmap:             true
            sourceSize.width:   width
            fillMode:           Image.PreserveAspectFit
            anchors.centerIn:   parent
        }

        Image {
            id:                     homePointer
            width:                  size * 0.1
            source:                 _showHomeHeadingCompass ? "/qmlimages/Home.svg" : ""
            mipmap:                 true
            fillMode:               Image.PreserveAspectFit
            anchors.centerIn:   	parent
            sourceSize.width:       width
            visible:                _showHomeHeadingCompass

            transform: Translate {
                x: size/2.3 * Math.sin((-_heading + _headingToHome)*(3.14/180))
                y: - size/2.3 * Math.cos((-_heading + _headingToHome)*(3.14/180))
            }
        }

        QGCColoredImage {
            id:                 compassDial
            source:             "/qmlimages/compassInstrumentDial.svg"
            mipmap:             true
            fillMode:           Image.PreserveAspectFit
            anchors.fill:       parent
            sourceSize.height:  parent.height
            color:              qgcPal.text
            transform: Rotation {
                origin.x:       compassDial.width  / 2
                origin.y:       compassDial.height / 2
                angle:          -_heading
            }
        }


        Rectangle {
            anchors.centerIn:   parent
            width:              size * 0.35
            height:             size * 0.2
            border.color:       qgcPal.text
            color:              qgcPal.window
            opacity:            0.65

            QGCLabel {
                text:               _headingString3
                font.family:        vehicle ? ScreenTools.demiboldFontFamily : ScreenTools.normalFontFamily
                font.pointSize:     _fontSize < 8 ? 8 : _fontSize;
                color:              qgcPal.text
                anchors.centerIn:   parent

                property string _headingString: vehicle ? _heading.toFixed(0) : "OFF"
                property string _headingString2: _headingString.length === 1 ? "0" + _headingString : _headingString
                property string _headingString3: _headingString2.length === 2 ? "0" + _headingString2 : _headingString2
            }
        }
    }

    Rectangle {
        id:             mask
        anchors.fill:   instrument
        radius:         width / 2
        color:          "black"
        visible:        false
    }

    OpacityMask {
        anchors.fill:   instrument
        source:         instrument
        maskSource:     mask
    }

}
