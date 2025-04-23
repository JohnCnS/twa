import 'dart:async';

import 'dart:js_interop';

import '../twa.dart';
import 'twa_interface.dart';

TwaInterface createTwa() {
  return TwaWeb();
}

class TwaWeb extends TwaInterface {
  TwaWeb();

  @override
  bool get isSupported => telegram.webApp.platform.toLowerCase() != 'unknown';

  @override
  WebAppInitData get initData =>
      WebAppInitData.fromRawString(telegram.webApp.initData);

  @override
  WebAppInitDataUnsafe get initDataUnsafe =>
      telegram.webApp.initDataUnsafe.toDart;

  @override
  String get platform => telegram.webApp.platform;

  @override
  String get version => telegram.webApp.version;

  @override
  LocationManager get locationManager {
    return telegram.webApp.locationManager.toDart;
  }

  @override
  Future<RequestContactResult> requestContact() async {
    final completer = Completer<RequestContactResult>();
    try {
      telegram.webApp.requestContact((
        bool isSent,
        RequestContactResult result,
      ) {
        completer.complete(result);
      });
    } catch (e) {
      completer.completeError(e);
    }
    return completer.future;
  }

  @override
  Future<bool> requestWriteAccess() {
    final completer = Completer<bool>();
    try {
      telegram.webApp.requestWriteAccess((isAccepted) {
        completer.complete(isAccepted);
      });
    } catch (e) {
      completer.completeError(e);
    }
    return completer.future;
  }

  @override
  void disableVerticalSwipes() {
    return telegram.webApp.disableVerticalSwipesJS();
  }

  @override
  void requestFullscreen() {
    return telegram.webApp.requestFullscreenJS();
  }

  @override
  void exitFullscreen() {
    return telegram.webApp.exitFullscreenJS();
  }

  @override
  void ready() {
    return telegram.webApp.ready();
  }
}

@JS('window.Telegram')
external TelegramJSObject get telegram;

extension type TelegramJSObject._(JSObject _) implements JSObject {
  @JS('WebApp')
  external WebAppJSObject get webApp;
}

extension type WebAppJSObject._(JSObject _) implements JSObject {
  external String get initData;

  external WebAppInitDataJSObject get initDataUnsafe;

  external String get platform;

  external String get version;

  @JS('LocationManager')
  external LocationManagerJSObject get locationManager;

  @JS("requestContact")
  external JSVoid requestContactJS(JSFunction callback);

  void requestContact(
    void Function(bool isSent, RequestContactResult result) callback,
  ) {
    requestContactJS(
      (JSBoolean isSent, RequestContactResultJSObject result) {
        callback(isSent.toDart, result.toDart);
      }.toJS,
    );
  }

  @JS("requestWriteAccess")
  external JSVoid requestWriteAccessJS(JSFunction callback);

  void requestWriteAccess(void Function(bool isAccepted) callback) {
    return requestWriteAccessJS(
      (bool isAccepted) {
        callback(isAccepted);
      }.toJS,
    );
  }

  @JS("disableVerticalSwipes")
  external JSVoid disableVerticalSwipesJS();

  @JS("requestFullscreen")
  external JSVoid requestFullscreenJS();

  @JS("exitFullscreen")
  external JSVoid exitFullscreenJS();

  external JSVoid ready();
}

Completer<void>? _locationInitCompleter;

extension type LocationManagerJSObject._(JSObject _) implements JSObject {
  external bool get isInited;

  external bool get isLocationAvailable;

  external bool get isAccessRequested;

  external bool get isAccessGranted;

  @JS("init")
  external JSVoid initJs(JSFunction callback);

  Future<void> init() {
    if (_locationInitCompleter?.isCompleted ?? false) {
      return _locationInitCompleter!.future;
    }

    _locationInitCompleter = Completer<void>();

    try {
      initJs(
        () {
          _locationInitCompleter?.complete();
        }.toJS,
      );
    } catch (e) {
      _locationInitCompleter?.completeError(e);
    }

    return _locationInitCompleter?.future ?? Future.value();
  }

  @JS("getLocation")
  external JSVoid getLocationJs(JSFunction callback);

  Future<LocationData?> getLocation() {
    final completer = Completer<LocationData?>();
    try {
      getLocationJs(
        ([LocationDataJSObject? data]) {
          completer.complete(data?.toDart);
        }.toJS,
      );
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future;
  }

  @JS("openSettings")
  external JSVoid openSettingsJs();

  void openSettings() {
    openSettingsJs();
  }

  LocationManager get toDart {
    return LocationManager(
      isInited: isInited,
      isLocationAvailable: isLocationAvailable,
      isAccessRequested: isAccessRequested,
      isAccessGranted: isAccessGranted,
      init: init,
      getLocation: getLocation,
      openSettings: openSettings,
    );
  }
}

extension type LocationDataJSObject._(JSObject _) implements JSObject {
  external double get latitude;
  external double get longitude;

  external double? get altitude;
  external double? get course;
  external double? get speed;
  external double? get horizontalAccuracy;
  external double? get verticalAccuracy;
  external double? get courseAccuracy;
  external double? get speedAccuracy;

  LocationData get toDart => LocationData(
    latitude: latitude,
    longitude: longitude,
    altitude: altitude,
    course: course,
    speed: speed,
    horizontalAccuracy: horizontalAccuracy,
    verticalAccuracy: verticalAccuracy,
    courseAccuracy: courseAccuracy,
    speedAccuracy: speedAccuracy,
  );
}

extension type WebAppInitDataJSObject._(JSObject _) implements JSObject {
  external String? get queryId;
  external WebAppUserJSObject? get user;
  external WebAppUserJSObject? get receiver;
  external WebAppChatJSObject? get chat;

  @JS('chat_type')
  external String? get chatType;

  @JS('chat_instance')
  external String? get chatInstance;

  @JS('start_param')
  external String? get startParam;

  @JS("can_send_after")
  external int? get canSendAfter;

  @JS('auth_date')
  external JSAny? get authDate;

  external String? get hash;

  external String? get signature;

  WebAppInitDataUnsafe get toDart {
    return WebAppInitDataUnsafe(
      user: user?.toDart,
      chatInstance: chatInstance ?? '',
      chatType: chatType ?? '',
      authDate: switch (authDate) {
        String str => int.parse(str),
        int num => num,
        JSNumber num => num.toDartInt,
        _ => -1,
      },
      signature: signature,
      hash: hash,
    );
  }
}

extension type WebAppChatJSObject._(JSObject _) implements JSObject {
  external int get id;
  external String get title;
  external String get type;
  external String? get username;
  external String? get photoUrl;

  WebAppChat get toDart => WebAppChat(
    id: id,
    title: title,
    type: type,
    username: username,
    photoUrl: photoUrl,
  );
}

extension type WebAppUserJSObject._(JSObject _) implements JSObject {
  external int get id;
  @JS('first_name')
  external String get firstName;
  @JS('last_name')
  external String? get lastName;
  external String? get username;
  @JS('photo_url')
  external String? get photoUrl;
  @JS('is_bot')
  external bool? get isBot;
  @JS('language_code')
  external String? get languageCode;
  @JS('is_premium')
  external bool? get isPremium;
  @JS('added_to_attachment_menu')
  external bool? get addedToAttachmentMenu;
  @JS('allows_write_to_pm')
  external bool? get allowsWriteToPm;

  WebAppUser get toDart {
    return WebAppUser(
      id: id,
      firstName: firstName,
      lastName: lastName,
      username: username,
      photoUrl: photoUrl,
      languageCode: languageCode,
      isPremium: isPremium,
      addedToAttachmentMenu: addedToAttachmentMenu,
      allowsWriteToPm: allowsWriteToPm,
      isBot: isBot,
    );
  }
}

extension type RequestContactResultJSObject._(JSObject _) implements JSObject {
  external String get status;
  external String? get response;
  external RequestContactResponseUnsafeJSObject? get responseUnsafe;

  RequestContactResult get toDart => RequestContactResult(
    status: status,
    response: switch (response) {
      String str => RequestContactResultResponse.fromRawString(str),
      _ => null,
    },
    responseUnsafe: responseUnsafe?.toDart,
  );
}

extension type RequestContactResponseUnsafeJSObject._(JSObject _)
    implements JSObject {
  external ContactJSObject get contact;
  @JS('auth_date')
  external String get authDate;

  external String get hash;

  RequestContactResultResponseUnsafe get toDart =>
      RequestContactResultResponseUnsafe(
        contact: contact.toDart,
        authDate: int.parse(authDate),
        hash: hash,
      );
}

extension type ContactJSObject._(JSObject _) implements JSObject {
  @JS('phone_number')
  external String get phoneNumber;
  @JS('first_name')
  external String get firstName;
  @JS('last_name')
  external String get lastName;
  @JS('user_id')
  external int userId;

  TelegramContact get toDart => TelegramContact(
    phoneNumber: phoneNumber,
    firstName: firstName,
    lastName: lastName,
    userId: userId,
  );
}
