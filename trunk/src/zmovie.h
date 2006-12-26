/*
Copyright (C) 1997-2006 ZSNES Team ( zsKnight, _Demo_, pagefault, Nach )

http://www.zsnes.com
http://sourceforge.net/projects/zsnes

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

#ifndef ZMOVIE_H
#define ZMOVIE_H

void mzt_chdir_up();
void mzt_chdir_down();
bool mzt_save(int, bool, bool);
bool mzt_load(int, bool);

extern unsigned char MovieProcessing;

enum MovieStatus { MOVIE_OFF = 0, MOVIE_PLAYBACK, MOVIE_RECORD, MOVIE_OLD_PLAY, MOVIE_ENDING_DUMPING };
#define SetMovieMode(mode) (MovieProcessing = (unsigned char)mode)


#endif