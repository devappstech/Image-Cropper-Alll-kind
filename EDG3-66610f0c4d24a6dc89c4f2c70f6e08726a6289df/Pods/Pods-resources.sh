#!/bin/sh
set -e

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
        echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1"`.mom\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd"
      ;;
    *.xcassets)
      ;;
    /*)
      echo "$1"
      echo "$1" >> "$RESOURCES_TO_COPY"
      ;;
    *)
      echo "${PODS_ROOT}/$1"
      echo "${PODS_ROOT}/$1" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
install_resource "Facebook-iOS-SDK/src/FBUserSettingsViewResources.bundle"
install_resource "Loopy/Loopy/Resources/FacebookLogoNoBlue43x43.png"
install_resource "Loopy/Loopy/Resources/FacebookLogoNoBlue60x60.png"
install_resource "Loopy/Loopy/Resources/FacebookLogoNoBlue76x76.png"
install_resource "Loopy/Loopy/Resources/TwitterLogo43x43.png"
install_resource "Loopy/Loopy/Resources/TwitterLogo60x60.png"
install_resource "Loopy/Loopy/Resources/TwitterLogo76x76.png"
install_resource "Loopy/Loopy/LoopyApiInfo.plist"
install_resource "Socialize/Socialize/Resources/action-bar-bg.png"
install_resource "Socialize/Socialize/Resources/action-bar-bg@2x.png"
install_resource "Socialize/Socialize/Resources/action-bar-button-black-hover-ios7.png"
install_resource "Socialize/Socialize/Resources/action-bar-button-black-hover-ios7@2x.png"
install_resource "Socialize/Socialize/Resources/action-bar-button-black-hover.png"
install_resource "Socialize/Socialize/Resources/action-bar-button-black-hover@2x.png"
install_resource "Socialize/Socialize/Resources/action-bar-button-black-ios7.png"
install_resource "Socialize/Socialize/Resources/action-bar-button-black-ios7@2x.png"
install_resource "Socialize/Socialize/Resources/action-bar-button-black.png"
install_resource "Socialize/Socialize/Resources/action-bar-button-black@2x.png"
install_resource "Socialize/Socialize/Resources/action-bar-button-red-hover-ios7.png"
install_resource "Socialize/Socialize/Resources/action-bar-button-red-hover-ios7@2x.png"
install_resource "Socialize/Socialize/Resources/action-bar-button-red-hover.png"
install_resource "Socialize/Socialize/Resources/action-bar-button-red-hover@2x.png"
install_resource "Socialize/Socialize/Resources/action-bar-button-red-ios7.png"
install_resource "Socialize/Socialize/Resources/action-bar-button-red-ios7@2x.png"
install_resource "Socialize/Socialize/Resources/action-bar-button-red.png"
install_resource "Socialize/Socialize/Resources/action-bar-button-red@2x.png"
install_resource "Socialize/Socialize/Resources/action-bar-icon-comments.png"
install_resource "Socialize/Socialize/Resources/action-bar-icon-comments@2x.png"
install_resource "Socialize/Socialize/Resources/action-bar-icon-like.png"
install_resource "Socialize/Socialize/Resources/action-bar-icon-like@2x.png"
install_resource "Socialize/Socialize/Resources/action-bar-icon-liked.png"
install_resource "Socialize/Socialize/Resources/action-bar-icon-liked@2x.png"
install_resource "Socialize/Socialize/Resources/action-bar-icon-share.png"
install_resource "Socialize/Socialize/Resources/action-bar-icon-share@2x.png"
install_resource "Socialize/Socialize/Resources/action-bar-icon-views.png"
install_resource "Socialize/Socialize/Resources/action-bar-icon-views@2x.png"
install_resource "Socialize/Socialize/Resources/background_brushed_metal@2x.png"
install_resource "Socialize/Socialize/Resources/background_plain@2x.png"
install_resource "Socialize/Socialize/Resources/comment-bg-ios7.png"
install_resource "Socialize/Socialize/Resources/comment-bg-ios7@2x.png"
install_resource "Socialize/Socialize/Resources/comment-bg.png"
install_resource "Socialize/Socialize/Resources/comment-bg@2x.png"
install_resource "Socialize/Socialize/Resources/comment-header-icon-ios7.png"
install_resource "Socialize/Socialize/Resources/comment-header-icon-ios7@2x.png"
install_resource "Socialize/Socialize/Resources/comment-header-icon.png"
install_resource "Socialize/Socialize/Resources/comment-header-icon@2x.png"
install_resource "Socialize/Socialize/Resources/comment-sm-icon.png"
install_resource "Socialize/Socialize/Resources/comment-sm-icon@2x.png"
install_resource "Socialize/Socialize/Resources/comments-cell-bg-borders.png"
install_resource "Socialize/Socialize/Resources/comments-cell-bg-borders@2x.png"
install_resource "Socialize/Socialize/Resources/FacebookLogoNoBlue43x43.png"
install_resource "Socialize/Socialize/Resources/FacebookLogoNoBlue60x60.png"
install_resource "Socialize/Socialize/Resources/FacebookLogoNoBlue76x76.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-bg.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-bg@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-call-out-arrow.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-call-out-arrow@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-cell-icon-comment-highlighted.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-cell-icon-comment-highlighted@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-cell-icon-comment-normal.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-cell-icon-comment-normal@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-cell-icon-comment.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-cell-icon-comment@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-cell-icon-facebook.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-cell-icon-facebook@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-cell-icon-like-highlighted.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-cell-icon-like-highlighted@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-cell-icon-like-normal.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-cell-icon-like-normal@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-cell-icon-like.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-cell-icon-like@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-cell-icon-share.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-cell-icon-share@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-cell-icon-twitter.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-cell-icon-twitter@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-details-back-entry-x.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-details-back-entry-x@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-details-back-section-x.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-details-back-section-x@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-details-btn-link-ios7.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-details-btn-link-ios7@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-details-btn-link.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-details-btn-link@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-details-categ_arrow.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-details-categ_arrow@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-details-ico-chat.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-details-ico-chat@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-details-ico-location.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-details-ico-location@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-details-profile-pic-small.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-details-profile-pic-small@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-details-top-back.png"
install_resource "Socialize/Socialize/Resources/socialize-activity-details-top-back@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-authorize-authenticate-badge-icon.png"
install_resource "Socialize/Socialize/Resources/socialize-authorize-authenticate-badge-icon@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-authorize-facebook-disabled-icon-ios7.png"
install_resource "Socialize/Socialize/Resources/socialize-authorize-facebook-disabled-icon-ios7@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-authorize-facebook-disabled-icon.png"
install_resource "Socialize/Socialize/Resources/socialize-authorize-facebook-disabled-icon@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-authorize-facebook-enabled-icon-ios7.png"
install_resource "Socialize/Socialize/Resources/socialize-authorize-facebook-enabled-icon-ios7@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-authorize-facebook-enabled-icon.png"
install_resource "Socialize/Socialize/Resources/socialize-authorize-facebook-enabled-icon@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-authorize-top-shadow-background.png"
install_resource "Socialize/Socialize/Resources/socialize-authorize-top-shadow-background@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-authorize-twitter-disabled-icon-ios7.png"
install_resource "Socialize/Socialize/Resources/socialize-authorize-twitter-disabled-icon-ios7@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-authorize-twitter-disabled-icon.png"
install_resource "Socialize/Socialize/Resources/socialize-authorize-twitter-disabled-icon@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-authorize-twitter-enabled-icon-ios7.png"
install_resource "Socialize/Socialize/Resources/socialize-authorize-twitter-enabled-icon-ios7@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-authorize-twitter-enabled-icon.png"
install_resource "Socialize/Socialize/Resources/socialize-authorize-twitter-enabled-icon@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-authorize-user-icon-ios7.png"
install_resource "Socialize/Socialize/Resources/socialize-authorize-user-icon-ios7@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-authorize-user-icon.png"
install_resource "Socialize/Socialize/Resources/socialize-authorize-user-icon@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-cell-arrow.png"
install_resource "Socialize/Socialize/Resources/socialize-cell-arrow@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-cell-bg.png"
install_resource "Socialize/Socialize/Resources/socialize-cell-bg@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-cell-image-bg.png"
install_resource "Socialize/Socialize/Resources/socialize-cell-image-bg@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-cell-image-default-ios7.png"
install_resource "Socialize/Socialize/Resources/socialize-cell-image-default-ios7@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-cell-image-default.png"
install_resource "Socialize/Socialize/Resources/socialize-cell-image-default@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-cell-image-mask-ios7.png"
install_resource "Socialize/Socialize/Resources/socialize-cell-image-mask-ios7@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-cell-image.png"
install_resource "Socialize/Socialize/Resources/socialize-cell-image@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-cell-selected-bg.png"
install_resource "Socialize/Socialize/Resources/socialize-cell-selected-bg@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-checkmark.png"
install_resource "Socialize/Socialize/Resources/socialize-checkmark@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-background-text-input-ios7.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-background-text-input-ios7@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-background-text-input.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-background-text-input@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-button-active.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-button-active@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-button.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-button@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-detail-bottom-shadow-background.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-detail-bottom-shadow-background@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-details-icon-geo-disabled.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-details-icon-geo-disabled@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-details-icon-geo-enabled.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-details-icon-geo-enabled@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-facebook-disabled.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-facebook-disabled@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-facebook-enabled.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-facebook-enabled@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-list-view-location-pin-icon.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-list-view-location-pin-icon@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-location-bar-background.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-location-bar-background@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-location-disabled.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-location-disabled@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-location-enabled.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-location-enabled@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-notification-disabled.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-notification-disabled@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-notification-enabled.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-notification-enabled@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-top-background.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-twitter-disabled.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-twitter-disabled@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-twitter-enabled.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-twitter-enabled@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-user-background.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-user-background@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-comment-user-only-background.png"
install_resource "Socialize/Socialize/Resources/socialize-iphone-notification-button-highlighted.png"
install_resource "Socialize/Socialize/Resources/socialize-iphone-notification-button-highlighted@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-iphone-notification-button-normal.png"
install_resource "Socialize/Socialize/Resources/socialize-iphone-notification-button-normal@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-iphone-subcribe-notification-icon.png"
install_resource "Socialize/Socialize/Resources/socialize-iphone-subcribe-notification-icon@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-location-icon.png"
install_resource "Socialize/Socialize/Resources/socialize-navbar-bg.png"
install_resource "Socialize/Socialize/Resources/socialize-navbar-bg@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-navbar-button-back-ios7.png"
install_resource "Socialize/Socialize/Resources/socialize-navbar-button-back-ios7@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-navbar-button-back-pressed.png"
install_resource "Socialize/Socialize/Resources/socialize-navbar-button-back-pressed@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-navbar-button-back.png"
install_resource "Socialize/Socialize/Resources/socialize-navbar-button-back@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-navbar-button-blue-bg-highlighted.png"
install_resource "Socialize/Socialize/Resources/socialize-navbar-button-blue-bg-highlighted@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-navbar-button-blue-bg-inactive.png"
install_resource "Socialize/Socialize/Resources/socialize-navbar-button-blue-bg-inactive@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-navbar-button-blue-bg-normal.png"
install_resource "Socialize/Socialize/Resources/socialize-navbar-button-blue-bg-normal@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-navbar-button-dark-active.png"
install_resource "Socialize/Socialize/Resources/socialize-navbar-button-dark-active@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-navbar-button-dark.png"
install_resource "Socialize/Socialize/Resources/socialize-navbar-button-dark@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-navbar-button-green-active.png"
install_resource "Socialize/Socialize/Resources/socialize-navbar-button-green-active@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-navbar-button-green.png"
install_resource "Socialize/Socialize/Resources/socialize-navbar-button-green@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-navbar-button-red-active.png"
install_resource "Socialize/Socialize/Resources/socialize-navbar-button-red-active@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-navbar-button-red.png"
install_resource "Socialize/Socialize/Resources/socialize-navbar-button-red@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-nocomments-icon.png"
install_resource "Socialize/Socialize/Resources/socialize-nocomments-icon@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-notifications-bottom-shadow-background.png"
install_resource "Socialize/Socialize/Resources/socialize-notifications-bottom-shadow-background@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-profileimage-large-bg-ios7.png"
install_resource "Socialize/Socialize/Resources/socialize-profileimage-large-bg-ios7@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-profileimage-large-bg.png"
install_resource "Socialize/Socialize/Resources/socialize-profileimage-large-bg@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-profileimage-large-default-ios7.png"
install_resource "Socialize/Socialize/Resources/socialize-profileimage-large-default-ios7@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-profileimage-large-default.png"
install_resource "Socialize/Socialize/Resources/socialize-profileimage-large-default@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-sectionheader-bg-ios7.png"
install_resource "Socialize/Socialize/Resources/socialize-sectionheader-bg-ios7@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-sectionheader-bg.png"
install_resource "Socialize/Socialize/Resources/socialize-sectionheader-bg@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-continue-btn.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-continue-btn@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-email-icon-ios7.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-email-icon-ios7@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-email-icon.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-email-icon@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-facebook-dis-icon-ios7.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-facebook-dis-icon-ios7@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-facebook-dis-icon.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-facebook-dis-icon@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-facebook-icon-ios7.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-facebook-icon-ios7@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-facebook-icon.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-facebook-icon@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-illustration.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-illustration@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-pinterest-icon-ios7.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-pinterest-icon-ios7@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-pinterest-icon.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-pinterest-icon@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-SMS-icon-ios7.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-SMS-icon-ios7@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-SMS-icon.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-SMS-icon@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-table-back.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-table-back@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-twitter-dis-icon-ios7.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-twitter-dis-icon-ios7@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-twitter-dis-icon.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-twitter-dis-icon@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-twitter-icon-ios7.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-twitter-icon-ios7@2x.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-twitter-icon.png"
install_resource "Socialize/Socialize/Resources/socialize-selectnetwork-twitter-icon@2x.png"
install_resource "Socialize/Socialize/Resources/socialize_logo.png"
install_resource "Socialize/Socialize/Resources/socialize_twitter_load.png"
install_resource "Socialize/Socialize/Resources/TwitterLogo43x43.png"
install_resource "Socialize/Socialize/Resources/TwitterLogo60x60.png"
install_resource "Socialize/Socialize/Resources/TwitterLogo76x76.png"
install_resource "Socialize/Socialize/Resources/_SZCommentsListViewController.xib"
install_resource "Socialize/Socialize/Resources/_SZComposeCommentViewController.xib"
install_resource "Socialize/Socialize/Resources/_SZLinkDialogViewController.xib"
install_resource "Socialize/Socialize/Resources/_SZTwitterLinkViewController.xib"
install_resource "Socialize/Socialize/Resources/_SZUserProfileViewController.xib"
install_resource "Socialize/Socialize/Resources/_SZUserSettingsViewController.xib"
install_resource "Socialize/Socialize/Resources/commentsNavBarLeftItemView.xib"
install_resource "Socialize/Socialize/Resources/CommentsTableViewCell.xib"
install_resource "Socialize/Socialize/Resources/CommentsTableViewCellIOS7.xib"
install_resource "Socialize/Socialize/Resources/SampleEntityLoader.xib"
install_resource "Socialize/Socialize/Resources/SocializeActivityDetailsViewController.xib"
install_resource "Socialize/Socialize/Resources/SocializeActivityTableViewCell.xib"
install_resource "Socialize/Socialize/Resources/SocializeActivityTableViewCellIOS7.xib"
install_resource "Socialize/Socialize/Resources/SocializeActivityViewController.xib"
install_resource "Socialize/Socialize/Resources/SocializeAuthInfoTableViewCell.xib"
install_resource "Socialize/Socialize/Resources/SocializeAuthTableViewCell.xib"
install_resource "Socialize/Socialize/Resources/SocializeCommentDetailsViewController.xib"
install_resource "Socialize/Socialize/Resources/SocializeComposeMessageViewController.xib"
install_resource "Socialize/Socialize/Resources/SocializeDummyViewController.xib"
install_resource "Socialize/Socialize/Resources/SocializeEditValueTableViewCell.xib"
install_resource "Socialize/Socialize/Resources/SocializeNotificationToggleBubbleContentView.xib"
install_resource "Socialize/Socialize/Resources/SocializeProfileEditTableViewCell.xib"
install_resource "Socialize/Socialize/Resources/SocializeProfileEditTableViewImageCell.xib"
install_resource "Socialize/Socialize/Resources/SocializeProfileEditValueViewController.xib"
install_resource "Socialize/Socialize/Resources/SocializeRichPushNotificationViewController.xib"
install_resource "Socialize/Socialize/Resources/SocializeTableViewController.xib"
install_resource "Socialize/Socialize/Resources/SZBaseShareViewController.xib"
install_resource "Socialize/Socialize/Resources/SZStatusImageLabelView.xib"
install_resource "Socialize/Socialize/Resources/LoopyApiInfo.plist"
install_resource "Socialize/Socialize/Resources/SocializeConfigurationInfo.plist"

rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]]; then
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ `xcrun --find actool` ] && [ `find . -name '*.xcassets' | wc -l` -ne 0 ]
then
  case "${TARGETED_DEVICE_FAMILY}" in 
    1,2)
      TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
      ;;
    1)
      TARGET_DEVICE_ARGS="--target-device iphone"
      ;;
    2)
      TARGET_DEVICE_ARGS="--target-device ipad"
      ;;
    *)
      TARGET_DEVICE_ARGS="--target-device mac"
      ;;  
  esac 
  find "${PWD}" -name "*.xcassets" -print0 | xargs -0 actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${IPHONEOS_DEPLOYMENT_TARGET}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
