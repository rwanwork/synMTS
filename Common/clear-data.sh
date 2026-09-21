#!/bin/bash
# Copyright 2026 Raymond Wan (rwan.work@gmail.com)
#   https://github.com/rwanwork/synMTS
#
# This file is part of synMTS.
#
# synMTS is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# synMTS is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program. If not, see <https://www.gnu.org/licenses/>.


cd Output/

rm -f -r evaluate/ select/ statistics/ Progress/ Manuscript/
rm -f -r generate/?/02*
rm -f -r generate/?/03*
rm -f -r generate/?/04*
rm -f -r generate/?/05*
rm -f -r generate/?/06*
rm -f -r generate/?/07*

cd ..
