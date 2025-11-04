qml_module(caelestia-internal
    URI Caelestia.Internal
    SOURCES
        cachingimagemanager.hpp cachingimagemanager.cpp
        circularindicatormanager.hpp circularindicatormanager.cpp
        # hyprdevices.hpp hyprdevices.cpp  # Disabled for MangoWC
        # hyprextras.hpp hyprextras.cpp    # Disabled for MangoWC
        logindmanager.hpp logindmanager.cpp
    LIBRARIES
        Qt::Gui
        Qt::Quick
        Qt::Concurrent
        Qt::Network
        Qt::DBus
)
