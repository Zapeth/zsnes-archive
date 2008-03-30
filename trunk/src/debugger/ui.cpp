/*
Copyright (C) 1997-2008 ZSNES Team ( zsKnight, _Demo_, pagefault, Nach )

http://www.zsnes.com
http://sourceforge.net/projects/zsnes
https://zsnes.bountysource.com

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
version 2 as published by the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

#include <QMessageBox>

#include "ui.h"

QtDebugger::QtDebugger(QWidget *parent) : QMainWindow(parent)
{
  ui.setupUi(this);
}

QtDebugger::~QtDebugger()
{

}

QtDebugger *QtDebugger::singleton = 0;

void QtDebugger::showQtDebugger(QWidget *parent)
{
  if (!singleton)
  {
    singleton = new QtDebugger(parent);
  }
  singleton->show();
}

void QtDebugger::destroyQtDebugger()
{
  if (singleton)
  {
    delete singleton;
    singleton = 0;
  }
}

extern "C" { extern unsigned char EMUPause; }

void QtDebugger::on_pauseButton_clicked()
{
  EMUPause ^= 1;
}

