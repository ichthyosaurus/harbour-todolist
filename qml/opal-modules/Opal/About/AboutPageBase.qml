/*
 * This file is part of opal-about.
 * SPDX-FileCopyrightText: 2020-2021 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import "private"

/*!
    \qmltype AboutPageBase
    \inqmlmodule Opal.About
    \inherits Page
    \brief Provides the base for custom About pages.

    The \c AboutPageBase is the basis for custom app info pages. App
    info pages normally contain information about the app's version,
    authors, and licensing.

    This component allows for the inclusion of standard info blocks
    for one or more licenses, authors, and contributors. You can add an
    arbitrary number of additional custom info sections.

    \section2 Licenses and Attribution

    Open-source licenses are specified by their \l {https://spdx.org/licenses/}
    {SPDX identifiers}. Follow the link for a list of valid strings.
    Custom licenses can be defined manually but are strongly discouraged.
    The license list (\l licenses) holds all licenses that are directly
    used in the project. Refer to the \l License component for more information.

    If your app relies on third-party services, e.g. data providers
    or for cloud functionalities, you should include a dedicated info
    section for each service that requires the user to accept Terms of Use
    or attribution. You can add links or open custom pages via the \c button
    property of \l InfoSection. Refer to \l InfoSection and \l extraSections
    for more information.

    \section2 Example Page

    The code below demonstrates an app info page for a simple project.
    One-person projects without other contributors or third-party attribution
    requirements (e.g. software libraries, etc.) can omit filling out
    \l contributionSections property.

    \qml
        import QtQuick 2.0
        import Sailfish.Silica 1.0
        import Opal.About 1.0

        AboutPageBase {
            id: page
            allowedOrientations: Orientation.All

            appName: qsTr("MyApp")
            iconSource: Qt.resolvedUrl("../images/harbour-myapp.png")
            versionNumber: APP_VERSION
            releaseNumber: APP_RELEASE
            description: qsTr("This is a short description of the app.")
            sourcesUrl: "https://github.com/Pretty-SFOS/opal-about"

            maintainer: "Au Thor"
            licenses: License {
                spdxId: "GPL-3.0-or-later"
                forComponents: ["MyApp"]
            }

            contributionSections: [
                ContributionSection {
                    title: qsTr("Development")
                    groups: [
                        ContributionGroup {
                            title: qsTr("Programming")
                            entries: ["Au Thor", "Jane Doe"]
                        },
                        ContributionGroup {
                            title: qsTr("Icon Design")
                            entries: ["Sailfish", "Jolla", "John Doe"]
                        }
                    ]
                },
                ContributionSection {
                    title: qsTr("Translations")
                    groups: [
                        ContributionGroup {
                            title: qsTr("English")
                            entries: ["Some Body"]
                        },
                        ContributionGroup {
                            title: qsTr("German")
                            entries: ["Max Mustermann"]
                        }
                    ]
                }
            ]
        }
    \endqml

    \section2 Custom Page Elements

    It is possible to add custom page elements to the end of the
    page by explicitly parenting them to the page's \l flickable property.
    You can, for example, add a pulley menu by setting its \c parent
    property to \c {page.flickable}:

    \qml
    PullDownMenu {
        parent: page.flickable
        MenuItem {
            text: qsTr("Open a page")
            onClicked: pageStack.push(Qt.resolvedUrl("Page.qml"))
        }
    }
    \endqml

    \section2 Translations

    The module provides all translations needed for the most common use-cases.
    Pre-translated strings include a range of language names as needed in
    the contributions info, strings for attribution of third-party libraries,
    and more. All common translations that are not directly used in this module
    are provided in the \c {Opal.About.Common} translation context. After
    translations have been merged you can go through your strings and
    mark all translations provided by \c lupdate's "same text" heuristic as
    "accepted". If you forget this step, these translations won't be used.

    You can use Qt's \c qsTranslate function and provide the context manually
    if you want to explicitly use a pre-translated string. This should not be
    necessary, though.

    \todo {how to include a section for donations}

    \sa License, InfoSection, ContributionSection, ContributionGroup
*/
Page {
    id: page
    allowedOrientations: Orientation.All

    /*!
      This property sets the app's name which will be displayed together with
      its logo and version string.

      \required
      \sa versionNumber releaseNumber
    */
    property string appName: ""

    /*!
      This property specifys the path to the app's logo.

      It is recommended to include the icon in your app's data directory.
      You can specify a full path to shared system files alternatively.

      \qml
      iconSource: Qt.resolvedUrl("../images/harbour-myapp.png")
      iconSource: "/usr/share/icons/hicolor/172x172/apps/harbour-myapp.png"
      \endqml

      Setting this property is not strictly required but highly recommended.

      \note You can use \opsnip {render-icons} to easily render icons to
      any destination.
    */
    property string iconSource: ""

    /*!
      This property holds the app's version number.

      Use for example \c APP_VERSION if configured via C++.
      \note You can use \opsnip {cached-defines} for passing options from
      YAML to QML.

      \required
      \sa releaseNumber
    */
    property string versionNumber: ""

    /*!
      This property holds the app's release number.
      Use for example \c APP_RELEASE if configured via C++
      \note You can use \opsnip {cached-defines} for passing options from
      YAML to QML.

      Setting this property is not required. It will only be shown
      if its value is not \c 1.

      \sa versionNumber
    */
    property string releaseNumber: "1"

    /*!
      This property holds a rich text description of the app.

      Sailfish-themed styling is applied by default. You can include
      links in text using \c {<a>} tags if needed. Depending on your
      use case it might be more appropriate to use a custom info
      section with a button though.

      \sa extraSections, InfoSection
    */
    property string description: ""

    /*!
      This property holds the app's main author(s) or maintainer(s).

      The default heading for this section may have to follow the gender of the
      person listed below in some languages. In this case, the default shipped
      translations should be used with caution and adapted if necessary.

      \note People's names should not be translated.

      \required
    */
    property string maintainer: ""

    /*!
      This property specifys where users can get the app's source code.

      If your app is open-source software it is recommended to include a
      link to a publicly accessible source code repository. This helps
      potential contributors. If you don't want to setup a public
      code repository you can add a custom info section with contact details.

      \note some open-source licenses require you to provide your app's source code.
    */
    property string sourcesUrl: ""

    /*!
      This property specifys where users can contribute to the app's translations.

      Helping with translations is a good way for non-technical users to contribute
      to open source projects they enjoy. Giving them the chance to do so gives
      warm and fuzzy feelings to everyone involved.

      \note \l {https://weblate.com} {Weblate} is an open source tool for
      translations. The community behind it provides a free service for
      applicable open source projects.
    */
    property string translationsUrl: ""

    /*!
      This property holds a list of relevant licenses.

      The very first licenses in this list is interpreted as the main
      licenses of the project and will be shown directly on the
      About page. If more than one license is specified, all
      additional licenses will be shown when clicking on the license
      section.

      Licenses are specified by their \l {https://spdx.org/licenses/}
      {SPDX identifiers}. You don't have to include any license
      texts manually. They will be automatically downloaded and cached
      locally. If a license text is not available locally and downloading
      is not possible, a short notice including a link to the full
      license text will be shown.

      \todo example

      \sa License
    */
    property list<License> licenses

    /*!
      This property holds a list of attributions, e.g. to third-party libraries.

      \todo example

      \sa Attribution
    */
    property list<Attribution> attributions

    /*!
      This property group holds a list of possible ways to donate to the project.

      \todo example

      \sa DonationService
    */
    readonly property DonationsGroup donations: DonationsGroup { }

    /*!
      This property holds a list of additional custom info sections.
      \todo {Where will they be shown?}
      \todo example
      \sa InfoSection
    */
    property list<InfoSection> extraSections

    /*!
      This property holds the definition of your apps contributors.

      You can leave this property empty if you are the only contributor.
      When this list is not empty, a page showing all contributions can
      be openend by clicking on the default author/maintainer section.

      The contributors page component is configured through this property
      and should not be used directly.

      \todo example

      \sa ContributionSection, ContributionGroup
    */
    property list<ContributionSection> contributionSections

    /*!
      This property references the page's main flickable.

      You can add custom page elements to the end of the
      page by explicitly parenting them to this property.
      You can, for example, add a pulley menu by setting its \c parent
      property to \c {page.flickable}:

      \qml
      PullDownMenu {
          parent: page.flickable
          MenuItem {
              text: qsTr("Open a page")
              onClicked: pageStack.push(Qt.resolvedUrl("Page.qml"))
          }
      }
      \endqml

      \sa SilicaFlickable, PullDownMenu
    */
    property alias flickable: _flickable

    /*!
      This property references the page's header item.
      \sa PageHeader
      \internal
    */
    property alias _pageHeaderItem: _pageHeader

    /*!
      This property references the app icon item.
      \sa Image
      \internal
    */
    property alias _iconItem: _icon

    /*!
      This property references the development info section.
      \sa InfoSection
      \internal
    */
    property alias _develInfoSection: _develInfo

    /*!
      This property references the license info section.
      \sa InfoSection
      \internal
    */
    property alias _contribInfoSection: _contribInfo

    /*!
      This property references the donations info section.
      \sa InfoSection
      \internal
    */
    property alias _donationsInfoSection: _donationsInfo

    SilicaFlickable {
        id: _flickable
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column

            PageHeader {
                id: _pageHeader
                title: qsTranslate("Opal.About", "About")
            }

            width: parent.width
            spacing: 1.5*Theme.paddingLarge

            Image {
                id: _icon
                anchors.horizontalCenter: parent.horizontalCenter
                width: Theme.itemSizeExtraLarge
                height: Theme.itemSizeExtraLarge
                fillMode: Image.PreserveAspectFit
                source: iconSource
                verticalAlignment: Image.AlignVCenter
            }

            Column {
                width: parent.width - 2*Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingSmall

                Label {
                    width: parent.width
                    visible: appName !== ""
                    text: appName
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeLarge
                    horizontalAlignment: Text.AlignHCenter
                }

                Label {
                    width: parent.width
                    visible: String(versionNumber !== "")
                    text: qsTranslate("Opal.About", "Version %1").arg(
                              String(releaseNumber === "1") ?
                                  versionNumber :
                                  versionNumber+"-"+releaseNumber)
                    color: Theme.secondaryHighlightColor
                    font.pixelSize: Theme.fontSizeMedium
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 2*Theme.horizontalPageMargin
                text: '<style type="text/css">A { color: "' +
                      String(palette.secondaryColor) +
                      '"; }</style>' + description
                onLinkActivated: Qt.openUrlExternally(link)
                wrapMode: Text.Wrap
                textFormat: Text.RichText
                horizontalAlignment: Text.AlignHCenter
                palette.primaryColor: Theme.highlightColor
            }

            InfoSection {
                id: _develInfo
                width: parent.width
                title: enabled ? qsTranslate("Opal.About", "Development") : qsTranslate("Opal.About", "Author")
                enabled: contributionSections.length > 0 || attributions.length > 0
                text: maintainer
                showMoreLabel: qsTranslate("Opal.About", "show contributors")
                backgroundItem.onClicked: {
                    pageStack.animatorPush("private/ContributorsPage.qml", {
                                               'sections': contributionSections,
                                               'attributions': attributions
                                           })
                }
            }

            Column {
                width: parent.width
                spacing: parent.spacing
                children: extraSections
            }

            InfoSection {
                id: _donationsInfo
                visible: donations.services.length > 0 || donations.text !== ''
                width: parent.width
                title: qsTranslate("Opal.About", "Donations")
                enabled: false
                text: donations.text === '' ? donations.defaultTextGeneral :
                                              donations.text
                __donationButtons: donations.services
            }

            InfoSection {
                id: _contribInfo
                width: parent.width
                title: qsTranslate("Opal.About", "License")
                enabled: licenses.length > 0
                backgroundItem.onClicked: pageStack.animatorPush("private/LicensePage.qml", {
                    'appName': appName, 'licenses': licenses, 'attributions': attributions })
                text: enabled === false ?
                          qsTranslate("Opal.About", "This is proprietary software. All rights reserved.") :
                          ((licenses[0].name !== "" && licenses[0].error !== true) ?
                               licenses[0].name + (licenses[0].customShortText === "" ?
                                                       "" :
                                                       "<br>"+licenses[0].customShortText) :
                               licenses[0].spdxId)
                showMoreLabel: qsTranslate("Opal.About", "show license(s)", "", licenses.length+attributions.length)
                buttons: [
                    InfoButton {
                        text: qsTranslate("Opal.About", "Translations")
                        onClicked: Qt.openUrlExternally(translationsUrl)
                        enabled: translationsUrl !== ''
                    },
                    InfoButton {
                        text: qsTranslate("Opal.About", "Source Code")
                        onClicked: Qt.openUrlExternally(sourcesUrl)
                        enabled: sourcesUrl !== ''
                    }
                ]

            }

            Item {
                id: bottomVerticalSpacing
                width: parent.width
                height: Theme.horizontalPageMargin
            }
        }
    }
}
