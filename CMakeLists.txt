cmake_minimum_required(VERSION 3.16)
project(PlasmaTherapy VERSION 1.0.0 LANGUAGES CXX)

# تنظیم استاندارد C++
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# پیدا کردن پکیج‌های Qt
find_package(Qt6 COMPONENTS Core Quick Qml Sql REQUIRED)

# تنظیم متغیرهای مسیر
set(PLASMA_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(PLASMA_BACKEND_DIR ${PLASMA_SOURCE_DIR}/backend)
set(PLASMA_QML_DIR_1 ${PLASMA_SOURCE_DIR}/UntitledProject1)
set(PLASMA_QML_DIR_2 ${PLASMA_SOURCE_DIR}/UntitledProject1Content)
set(PLASMA_ASSETS_DIR ${PLASMA_QML_DIR_2}/images)
set(PLASMA_FONTS_DIR ${PLASMA_QML_DIR_2}/fonts)

# تنظیم متغیرهای نصب
set(PLASMA_INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/share/plasma_therapy)
set(PLASMA_BIN_DIR ${CMAKE_INSTALL_PREFIX}/bin)

# جمع‌آوری فایل‌های پایتون
file(GLOB PYTHON_FILES
    ${PLASMA_SOURCE_DIR}/main.py
    ${PLASMA_BACKEND_DIR}/*.py
)

# استفاده از فایل QRC دستی
qt_add_resources(RESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/resources.qrc)

# ایجاد فایل اجرایی C++ برای راه‌اندازی برنامه پایتون
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/main_wrapper.cpp.in
    ${CMAKE_CURRENT_BINARY_DIR}/main_wrapper.cpp
    @ONLY
)

# اضافه کردن فایل اجرایی
add_executable(plasma_therapy
    ${CMAKE_CURRENT_BINARY_DIR}/main_wrapper.cpp
    ${RESOURCES}
)

# لینک کردن کتابخانه‌های Qt
target_link_libraries(plasma_therapy PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Qml
    Qt6::Sql
)

# ایجاد اسکریپت اجرایی برای لینوکس
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/plasma_therapy.sh.in
    ${CMAKE_CURRENT_BINARY_DIR}/plasma_therapy.sh
    @ONLY
)

# نصب فایل‌های پایتون
install(FILES ${PYTHON_FILES}
        DESTINATION ${PLASMA_INSTALL_DIR})

# نصب دایرکتوری‌های پروژه
install(DIRECTORY 
        ${PLASMA_SOURCE_DIR}/UntitledProject1
        ${PLASMA_SOURCE_DIR}/UntitledProject1Content
        ${PLASMA_SOURCE_DIR}/backend
        DESTINATION ${PLASMA_INSTALL_DIR})

# نصب فایل‌های اضافی
install(FILES 
        ${PLASMA_SOURCE_DIR}/qtquickcontrols2.conf
        ${PLASMA_SOURCE_DIR}/UntitledProject1.qmlproject
        ${PLASMA_SOURCE_DIR}/resources.qrc
        DESTINATION ${PLASMA_INSTALL_DIR})

# نصب دایرکتوری دیتابیس
install(DIRECTORY ${PLASMA_SOURCE_DIR}/db
        DESTINATION ${PLASMA_INSTALL_DIR})

# نصب فایل اجرایی
install(TARGETS plasma_therapy
        DESTINATION ${PLASMA_BIN_DIR})

# نصب اسکریپت اجرایی
install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/plasma_therapy.sh
        DESTINATION ${PLASMA_BIN_DIR}
        RENAME plasma_therapy_run)

# تنظیم فایل desktop برای نصب در لینوکس
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/plasma_therapy.desktop.in
               ${CMAKE_CURRENT_BINARY_DIR}/plasma_therapy.desktop @ONLY)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/plasma_therapy.desktop
        DESTINATION ${CMAKE_INSTALL_PREFIX}/share/applications)

# پیکربندی بسته
include(CPack)
set(CPACK_GENERATOR "DEB")
set(CPACK_PACKAGE_NAME "plasma-therapy")
set(CPACK_PACKAGE_VENDOR "Plasma Therapy")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Plasma Therapy Application For AEOI plasma Company")
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_PACKAGE_CONTACT "khosroanjam@gmail.com")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "python3 (>= 3.8), python3-pyside6 (>= 6.0), python3-rpi.gpio")