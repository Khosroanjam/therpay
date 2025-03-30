#!/bin/bash
# این فایل به عنوان اسکریپت اجرایی برنامه استفاده می‌شود

# تنظیم مسیرها
INSTALL_DIR="/usr/local/share/plasma_therapy"
PYTHON_MAIN="${INSTALL_DIR}/main.py"

# تغییر به دایرکتوری نصب
cd "${INSTALL_DIR}" || exit 1

# اجرای برنامه
python3 "${PYTHON_MAIN}" "$@"
