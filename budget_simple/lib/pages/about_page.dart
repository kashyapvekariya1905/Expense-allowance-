import 'dart:io';

import 'package:budget_simple/database/tables.dart';
import 'package:budget_simple/main.dart';
import 'package:budget_simple/pages/home_page.dart';
import 'package:budget_simple/struct/colors.dart';
import 'package:budget_simple/struct/database_global.dart';
import 'package:budget_simple/struct/functions.dart';
import 'package:budget_simple/struct/languages_dict.dart';
import 'package:budget_simple/struct/notifications.dart';
import 'package:budget_simple/struct/translations.dart';
import 'package:budget_simple/widgets/page_framework.dart';
import 'package:budget_simple/widgets/select_color.dart';
import 'package:budget_simple/widgets/settings_container.dart';
import 'package:budget_simple/widgets/support_developer.dart';
import 'package:budget_simple/widgets/tappable.dart';
import 'package:budget_simple/widgets/text_font.dart';
import 'package:budget_simple/widgets/time_digits.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      childBuilder: (scrollController) => Scaffold(
        appBar: AppBar(
          title: const TextFont(text: "Settings"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              if (Platform.isIOS == false) const CashewPromo(),
              if (Platform.isIOS == false) const SizedBox(height: 5),
              if (Platform.isIOS == false)
                const TextFont(
                  text: "From the same developer!",
                  fontSize: 15,
                ),
              if (Platform.isIOS == false) const SizedBox(height: 10),
              if (Platform.isIOS == false) const SupportDeveloper(),
              // kIsWeb
              //     ? const SizedBox.shrink()
              //     : SettingsContainer(
              //         title: "Rate",
              //         afterWidget: const Icon(
              //           Icons.arrow_forward_ios_rounded,
              //           size: 17,
              //         ),
              //         icon: Icons.star_border,
              //         onTap: () async {
              //           if (await inAppReview.isAvailable()) {
              //             inAppReview.requestReview();
              //           } else {
              //             inAppReview.openStoreListing();
              //           }
              //         },
              //       ),
              kIsWeb
                  ? SettingsContainer(
                      title: "Donate",
                      afterWidget: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 17,
                      ),
                      icon: Icons.thumb_up_alt_outlined,
                      onTap: () {
                        kIsWeb
                            ? openUrl("https://ko-fi.com/dapperappdeveloper")
                            : null;
                      },
                    )
                  : const SizedBox.shrink(),
              
              const Divider(),
              Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                  child: SizedBox(
                    height: 65,
                    child: SelectColor(
                      setSelectedColor: (Color? color) {
                        themeColor = color;
                        if (color == null) {
                          sharedPreferences.remove("themeColor");
                        } else {
                          sharedPreferences.setString(
                              "themeColor", colorToString(color) ?? "");
                        }
                        initializeAppStateKey.currentState?.refreshAppState();
                      },
                      selectedColor: themeColor,
                    ),
                  ),
                ),
              ),
              SettingsContainerDropdown(
                icon: Icons.lightbulb_outline,
                title: "Theme Mode",
                initial: themeMode,
                items: const ["System", "Light", "Dark"],
                onChanged: (selected) {
                  themeMode = selected;
                  sharedPreferences.setString("themeMode", selected);
                  initializeAppStateKey.currentState?.refreshAppState();
                },
                getLabel: (label) {
                  return label;
                },
              ),
              SettingsContainer(
                title: "Reset Allowance",
                afterWidget: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 17,
                ),
                icon: Icons.arrow_circle_up_rounded,
                onTap: () {
                  addAmountBottomSheet(context);
                },
              ),
              SettingsContainer(
                title: "Change Currency",
                afterWidget: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 17,
                ),
                icon: Icons.category_outlined,
                onTap: () {
                  changeCurrencyIconBottomSheet(context);
                },
              ),
              SettingsContainerDropdown(
                translate: false,
                icon: Icons.language,
                title: "Language",
                initial: language,
                items: ["Default", ...languagesDictionary.keys.toList()],
                onChanged: (selected) {
                  if (selected == "Default") {
                    language = getDeviceLanguage() ?? "en";
                    sharedPreferences.remove("language");
                  } else {
                    language = selected;
                    sharedPreferences.setString("language", selected);
                  }
                  initializeAppStateKey.currentState?.refreshAppState();
                },
                getLabel: (label) {
                  if (label == "Default") return translateText("Default");
                  return languagesDictionary[label] ?? "English";
                },
              ),
              SettingsContainerSwitch(
                title: "Haptic Feedback",
                onSwitched: (value) {
                  sharedPreferences.setBool("hapticFeedback", value);
                },
                initialValue:
                    sharedPreferences.getBool("hapticFeedback") ?? true,
                icon: Icons.vibration_rounded,
              ),
              kIsWeb ? const SizedBox.shrink() : const NotificationSettings(),
              const Divider(),
              const SizedBox(height: 10),
              
              const AboutInfoBox(
                title: "Contact",
                displayLink: "kashyapmvekariya1905@gmail.com",
                link: "mailto:kashyapmvekariya1905@gmail.com",
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  bool notificationsEnabled = notifications;
  TimeOfDay timeOfDay = notificationsTime;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingsContainerSwitch(
          title: "Daily Notifications",
          onSwitched: (value) {
            setState(() {
              notificationsEnabled = value;
              notifications = value;
              sharedPreferences.setBool("notifications", value);
            });
            if (value) {
              setDailyNotificationOnLaunch(context);
            } else {
              cancelDailyNotification();
            }
          },
          initialValue: notificationsEnabled,
          icon: Icons.notifications_outlined,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 900),
          curve: Curves.elasticOut,
          child: notificationsEnabled
              ? SettingsContainer(
                  title: "Notification Time",
                  afterWidget: TimeDigits(
                    timeOfDay: timeOfDay,
                  ),
                  icon: Icons.alarm_outlined,
                  onTap: () async {
                    TimeOfDay? newTime = await showTimePicker(
                      context: context,
                      initialTime: timeOfDay,
                      initialEntryMode: TimePickerEntryMode.input,
                      helpText: "",
                    );
                    if (newTime == null) return;
                    timeOfDay = newTime;
                    notificationsTime = newTime;
                    sharedPreferences.setString("notificationsTime",
                        "${newTime.hour}:${newTime.minute}");
                    setState(() {});
                    setDailyNotificationOnLaunch(context);
                  },
                )
              : Container(),
        ),
      ],
    );
  }
}

class DonationMenuItem extends StatelessWidget {
  const DonationMenuItem({
    super.key,
    required this.onTap,
    required this.imagePath,
    required this.subheader,
  });
  final String imagePath;
  final VoidCallback onTap;
  final String subheader;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      color: Theme.of(context).canvasColor.withOpacity(0.6),
      borderRadius: 20,
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          children: [
            const SizedBox(
              height: 2,
            ),
            SizedBox(
              width: 60,
              child: Image(
                image: AssetImage(imagePath),
              ),
            ),
            const SizedBox(
              height: 11,
            ),
            TextFont(
              text: subheader,
              fontSize: 13,
            ),
            const SizedBox(
              height: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class AboutInfoBox extends StatelessWidget {
  const AboutInfoBox({
    Key? key,
    required this.title,
    required this.link,
    this.displayLink,
  }) : super(key: key);

  final String title;
  final String link;
  final String? displayLink;

  @override
  Widget build(BuildContext context) {
    const double maxWidth = 450;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: maxWidth),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 5),
        child: Tappable(
          onTap: () async {
            openUrl(link);
          },
          color:
              Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
          borderRadius: 15,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Column(
                    children: [
                      TextFont(
                        text: title,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                        maxLines: 5,
                        filter: (text) {
                          return text.capitalizeFirstofEach;
                        },
                      ),
                      const SizedBox(height: 6),
                      TextFont(
                        text: displayLink ?? link,
                        fontSize: 13,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
