/*
 * ***** BEGIN GPL LICENSE BLOCK *****
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 * Contributor(s): Tao Ju
 *
 * ***** END GPL LICENSE BLOCK *****
 */

#include "marching_cubes_table.h"

/* number of triangles in each configuration */
const int marching_cubes_numtri[TOTCONF] = {
	0, 1, 1, 2, 1, 2, 4, 3, 1, 4, 2, 3, 2, 3, 3, 2, 1, 2, 4, 3, 4, 3, 5, 4,
	6, 5, 5, 4, 5, 4, 4, 3, 1, 4, 2, 3, 6, 5, 5, 4, 4, 5, 3, 4, 5, 4, 4, 3,
	2, 3, 3, 2, 5, 4, 4, 3, 5, 4, 4, 3, 4, 3, 3, 2, 1, 4, 6, 5, 2, 3, 5, 4,
	4, 5, 5, 4, 3, 4, 4, 3, 2, 3, 5, 4, 3, 2, 4, 3, 5, 4, 4, 3, 4, 3, 3, 2,
	4, 5, 5, 4, 5, 4, 4, 3, 5, 4, 4, 3, 4, 3, 3, 2, 3, 4, 4, 3, 4, 3, 3, 2,
	4, 3, 3, 2, 3, 2, 2, 1, 1, 6, 4, 5, 4, 5, 5, 4, 2, 5, 3, 4, 3, 4, 4, 3,
	4, 5, 5, 4, 5, 4, 4, 3, 5, 4, 4, 3, 4, 3, 3, 2, 2, 5, 3, 4, 5, 4, 4, 3,
	3, 4, 2, 3, 4, 3, 3, 2, 3, 4, 4, 3, 4, 3, 3, 2, 4, 3, 3, 2, 3, 2, 2, 1,
	2, 5, 5, 4, 3, 4, 4, 3, 3, 4, 4, 3, 2, 3, 3, 2, 3, 4, 4, 3, 4, 3, 3, 2,
	4, 3, 3, 2, 3, 2, 2, 1, 3, 4, 4, 3, 4, 3, 3, 2, 4, 3, 3, 2, 3, 2, 2, 1,
	2, 3, 3, 2, 3, 2, 2, 1, 3, 2, 2, 1, 2, 1, 1, 0
};

/* table of triangles in each configuration */
const int marching_cubes_tris[TOTCONF][MAX_TRIS][3] = {
	{{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 0, 8}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 1, 5}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 0, 1}, {4, 1, 5}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 9, 2}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 8, 9}, {0, 9, 2}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{1, 5, 9}, {1, 9, 2}, {1, 2, 4}, {1, 4, 8}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 1, 5}, {0, 5, 9}, {0, 9, 2}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{5, 3, 9}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 8, 5}, {0, 5, 3}, {0, 3, 9}, {0, 9, 4}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 1, 3}, {8, 3, 9}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 0, 1}, {4, 1, 3}, {4, 3, 9}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 5, 3}, {4, 3, 2}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 8, 5}, {0, 5, 3}, {0, 3, 2}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 8, 1}, {4, 1, 3}, {4, 3, 2}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 1, 3}, {0, 3, 2}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 6, 10}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 4, 6}, {8, 6, 10}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 10, 1}, {6, 1, 5}, {6, 5, 8}, {6, 8, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 6, 10}, {4, 10, 1}, {4, 1, 5}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 0, 4}, {10, 4, 9}, {10, 9, 2}, {10, 2, 6}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 10, 8}, {6, 8, 9}, {6, 9, 2}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 8, 0}, {6, 10, 1}, {6, 1, 5}, {6, 5, 9}, {6, 9, 2},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 10, 1}, {6, 1, 5}, {6, 5, 9}, {6, 9, 2}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 0, 5}, {0, 6, 9}, {9, 5, 0}, {6, 10, 3}, {5, 3, 10},
	 {3, 9, 6}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 8, 5}, {10, 5, 3}, {9, 4, 6}, {6, 10, 3}, {6, 3, 9},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 1, 3}, {9, 8, 0}, {9, 0, 6}, {6, 10, 3}, {6, 3, 9},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 6, 10}, {4, 10, 1}, {4, 1, 3}, {4, 3, 9}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 4, 5}, {3, 2, 6}, {3, 6, 10}, {10, 0, 5}, {10, 5, 3},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 10, 8}, {6, 8, 5}, {6, 5, 3}, {6, 3, 2}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 8, 0}, {6, 10, 1}, {6, 1, 3}, {6, 3, 2}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 10, 1}, {6, 1, 3}, {6, 3, 2}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 7, 1}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 0, 10}, {4, 10, 7}, {4, 7, 1}, {4, 1, 8}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 10, 7}, {8, 7, 5}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 0, 10}, {4, 10, 7}, {4, 7, 5}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 2, 4}, {10, 4, 1}, {7, 2, 10}, {1, 9, 7}, {1, 4, 9},
	 {9, 2, 7}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{1, 8, 9}, {2, 0, 10}, {2, 10, 7}, {7, 1, 9}, {7, 9, 2},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 8, 10}, {7, 5, 9}, {7, 9, 2}, {2, 4, 10}, {2, 10, 7},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 10, 7}, {0, 7, 5}, {0, 5, 9}, {0, 9, 2}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 7, 3}, {10, 3, 9}, {10, 9, 5}, {10, 5, 1}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 5, 1}, {4, 0, 10}, {4, 10, 7}, {4, 7, 3}, {4, 3, 9},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 10, 7}, {8, 7, 3}, {8, 3, 9}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 0, 10}, {4, 10, 7}, {4, 7, 3}, {4, 3, 9}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 5, 1}, {4, 1, 10}, {7, 3, 2}, {2, 4, 10}, {2, 10, 7},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 5, 1}, {0, 10, 7}, {0, 7, 3}, {0, 3, 2}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 8, 10}, {4, 10, 7}, {4, 7, 3}, {4, 3, 2}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 10, 7}, {0, 7, 3}, {0, 3, 2}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 6, 7}, {0, 7, 1}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 4, 6}, {8, 6, 7}, {8, 7, 1}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 0, 6}, {8, 6, 7}, {8, 7, 5}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 6, 7}, {4, 7, 5}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{1, 0, 4}, {1, 4, 9}, {2, 6, 7}, {7, 1, 9}, {7, 9, 2},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 7, 1}, {6, 1, 8}, {6, 8, 9}, {6, 9, 2}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 8, 0}, {6, 7, 5}, {6, 5, 9}, {6, 9, 2}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 7, 5}, {6, 5, 9}, {6, 9, 2}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{5, 1, 0}, {6, 7, 3}, {6, 3, 9}, {9, 5, 0}, {9, 0, 6},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 5, 1}, {4, 6, 7}, {4, 7, 3}, {4, 3, 9}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 0, 6}, {8, 6, 7}, {8, 7, 3}, {8, 3, 9}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 6, 7}, {4, 7, 3}, {4, 3, 9}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 4, 5}, {0, 5, 1}, {6, 7, 3}, {6, 3, 2}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 5, 1}, {6, 7, 3}, {6, 3, 2}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 8, 0}, {6, 7, 3}, {6, 3, 2}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 7, 3}, {6, 3, 2}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 2, 11}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 4, 2}, {8, 2, 11}, {8, 11, 6}, {8, 6, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 1, 6}, {6, 1, 11}, {11, 1, 5}, {2, 11, 5}, {2, 5, 8},
	 {6, 2, 8}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 0, 1}, {5, 4, 2}, {5, 2, 11}, {11, 6, 1}, {11, 1, 5},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 4, 9}, {6, 9, 11}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 0, 8}, {6, 8, 9}, {6, 9, 11}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 4, 8}, {6, 8, 1}, {5, 9, 11}, {11, 6, 1}, {11, 1, 5},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 0, 1}, {6, 1, 5}, {6, 5, 9}, {6, 9, 11}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 2, 9}, {6, 9, 5}, {6, 5, 3}, {6, 3, 11}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 2, 9}, {6, 0, 8}, {6, 8, 5}, {6, 5, 3}, {6, 3, 11},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{2, 9, 8}, {1, 3, 11}, {1, 11, 6}, {6, 2, 8}, {6, 8, 1},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 2, 9}, {6, 0, 1}, {6, 1, 3}, {6, 3, 11}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 4, 5}, {6, 5, 3}, {6, 3, 11}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 0, 8}, {6, 8, 5}, {6, 5, 3}, {6, 3, 11}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 4, 8}, {6, 8, 1}, {6, 1, 3}, {6, 3, 11}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 0, 1}, {6, 1, 3}, {6, 3, 11}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 0, 2}, {10, 2, 11}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 8, 4}, {10, 4, 2}, {10, 2, 11}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 0, 2}, {11, 10, 1}, {11, 1, 5}, {5, 8, 2}, {5, 2, 11},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 1, 5}, {10, 5, 4}, {10, 4, 2}, {10, 2, 11}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 0, 4}, {10, 4, 9}, {10, 9, 11}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 8, 9}, {10, 9, 11}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 8, 0}, {10, 1, 5}, {10, 5, 9}, {10, 9, 11}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 1, 5}, {10, 5, 9}, {10, 9, 11}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 2, 9}, {0, 9, 5}, {3, 11, 10}, {10, 0, 5}, {10, 5, 3},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 2, 9}, {10, 8, 5}, {10, 5, 3}, {10, 3, 11}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 0, 2}, {8, 2, 9}, {10, 1, 3}, {10, 3, 11}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 2, 9}, {10, 1, 3}, {10, 3, 11}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 0, 4}, {10, 4, 5}, {10, 5, 3}, {10, 3, 11}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 8, 5}, {10, 5, 3}, {10, 3, 11}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 8, 0}, {10, 1, 3}, {10, 3, 11}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 1, 3}, {10, 3, 11}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{1, 10, 6}, {1, 6, 2}, {1, 2, 11}, {1, 11, 7}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 10, 6}, {7, 1, 8}, {7, 8, 4}, {7, 4, 2}, {7, 2, 11},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 10, 6}, {8, 6, 2}, {11, 7, 5}, {5, 8, 2}, {5, 2, 11},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 10, 6}, {7, 5, 4}, {7, 4, 2}, {7, 2, 11}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 6, 4}, {9, 11, 7}, {9, 7, 1}, {1, 10, 4}, {1, 4, 9},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 10, 6}, {7, 1, 8}, {7, 8, 9}, {7, 9, 11}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 8, 10}, {4, 10, 6}, {7, 5, 9}, {7, 9, 11}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 10, 6}, {7, 5, 9}, {7, 9, 11}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{5, 1, 10}, {5, 10, 6}, {5, 6, 2}, {5, 2, 9}, {7, 3, 11},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 10, 6}, {8, 5, 1}, {4, 2, 9}, {7, 3, 11}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 10, 6}, {8, 6, 2}, {8, 2, 9}, {7, 3, 11}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 10, 6}, {4, 2, 9}, {7, 3, 11}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 6, 4}, {10, 4, 5}, {10, 5, 1}, {7, 3, 11}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 10, 6}, {8, 5, 1}, {7, 3, 11}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 8, 10}, {4, 10, 6}, {7, 3, 11}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 10, 6}, {7, 3, 11}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{7, 1, 0}, {7, 0, 2}, {7, 2, 11}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{7, 1, 8}, {7, 8, 4}, {7, 4, 2}, {7, 2, 11}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{7, 5, 8}, {7, 8, 0}, {7, 0, 2}, {7, 2, 11}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{7, 5, 4}, {7, 4, 2}, {7, 2, 11}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{7, 1, 0}, {7, 0, 4}, {7, 4, 9}, {7, 9, 11}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{7, 1, 8}, {7, 8, 9}, {7, 9, 11}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 8, 0}, {7, 5, 9}, {7, 9, 11}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{7, 5, 9}, {7, 9, 11}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{5, 1, 0}, {5, 0, 2}, {5, 2, 9}, {7, 3, 11}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 5, 1}, {4, 2, 9}, {7, 3, 11}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 0, 2}, {8, 2, 9}, {7, 3, 11}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 2, 9}, {7, 3, 11}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 4, 5}, {0, 5, 1}, {7, 3, 11}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 5, 1}, {7, 3, 11}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 8, 0}, {7, 3, 11}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{7, 3, 11}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{7, 11, 3}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{7, 11, 0}, {7, 0, 8}, {0, 11, 4}, {8, 3, 7}, {11, 3, 4},
	 {3, 8, 4}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 1, 7}, {8, 7, 11}, {8, 11, 3}, {8, 3, 5}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 1, 7}, {0, 7, 11}, {3, 5, 4}, {4, 0, 11}, {4, 11, 3},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 9, 3}, {4, 3, 7}, {4, 7, 11}, {4, 11, 2}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 9, 3}, {8, 3, 7}, {11, 2, 0}, {0, 8, 7}, {0, 7, 11},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{5, 9, 3}, {4, 8, 1}, {4, 1, 7}, {4, 7, 11}, {4, 11, 2},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{5, 9, 3}, {0, 1, 7}, {0, 7, 11}, {0, 11, 2}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{5, 7, 11}, {5, 11, 9}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 5, 7}, {11, 9, 4}, {11, 4, 0}, {0, 8, 7}, {0, 7, 11},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 1, 7}, {8, 7, 11}, {8, 11, 9}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 0, 1}, {4, 1, 7}, {4, 7, 11}, {4, 11, 9}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 5, 7}, {4, 7, 11}, {4, 11, 2}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 8, 5}, {0, 5, 7}, {0, 7, 11}, {0, 11, 2}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 8, 1}, {4, 1, 7}, {4, 7, 11}, {4, 11, 2}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 1, 7}, {0, 7, 11}, {0, 11, 2}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 6, 11}, {0, 11, 3}, {0, 3, 7}, {0, 7, 10}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{7, 10, 8}, {4, 6, 11}, {4, 11, 3}, {3, 7, 8}, {3, 8, 4},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 1, 7}, {5, 8, 0}, {5, 0, 6}, {5, 6, 11}, {5, 11, 3},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 1, 7}, {5, 4, 6}, {5, 6, 11}, {5, 11, 3}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{7, 10, 0}, {7, 0, 4}, {7, 4, 9}, {7, 9, 3}, {6, 11, 2},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{7, 10, 8}, {7, 8, 9}, {7, 9, 3}, {6, 11, 2}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 8, 0}, {10, 1, 7}, {5, 9, 3}, {6, 11, 2}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 1, 7}, {5, 9, 3}, {6, 11, 2}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{5, 7, 10}, {5, 10, 0}, {6, 11, 9}, {9, 5, 0}, {9, 0, 6},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 8, 5}, {10, 5, 7}, {4, 6, 11}, {4, 11, 9}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 1, 7}, {8, 0, 6}, {8, 6, 11}, {8, 11, 9}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 1, 7}, {4, 6, 11}, {4, 11, 9}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 0, 4}, {10, 4, 5}, {10, 5, 7}, {6, 11, 2}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 8, 5}, {10, 5, 7}, {6, 11, 2}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 8, 0}, {10, 1, 7}, {6, 11, 2}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 1, 7}, {6, 11, 2}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{1, 10, 11}, {1, 11, 3}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 10, 11}, {3, 1, 8}, {3, 8, 4}, {4, 0, 11}, {4, 11, 3},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{5, 8, 10}, {5, 10, 11}, {5, 11, 3}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{5, 4, 0}, {5, 0, 10}, {5, 10, 11}, {5, 11, 3}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{9, 3, 1}, {10, 11, 2}, {10, 2, 4}, {4, 9, 1}, {4, 1, 10},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{1, 8, 9}, {1, 9, 3}, {0, 10, 11}, {0, 11, 2}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{5, 9, 3}, {4, 8, 10}, {4, 10, 11}, {4, 11, 2}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{5, 9, 3}, {0, 10, 11}, {0, 11, 2}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{5, 1, 10}, {5, 10, 11}, {5, 11, 9}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 5, 1}, {4, 0, 10}, {4, 10, 11}, {4, 11, 9}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 10, 11}, {8, 11, 9}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 0, 10}, {4, 10, 11}, {4, 11, 9}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 5, 1}, {4, 1, 10}, {4, 10, 11}, {4, 11, 2}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 5, 1}, {0, 10, 11}, {0, 11, 2}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 8, 10}, {4, 10, 11}, {4, 11, 2}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 10, 11}, {0, 11, 2}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{1, 0, 6}, {1, 6, 11}, {1, 11, 3}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{1, 8, 4}, {1, 4, 6}, {1, 6, 11}, {1, 11, 3}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{5, 8, 0}, {5, 0, 6}, {5, 6, 11}, {5, 11, 3}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{5, 4, 6}, {5, 6, 11}, {5, 11, 3}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{1, 0, 4}, {1, 4, 9}, {1, 9, 3}, {6, 11, 2}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{1, 8, 9}, {1, 9, 3}, {6, 11, 2}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 8, 0}, {5, 9, 3}, {6, 11, 2}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{5, 9, 3}, {6, 11, 2}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{5, 1, 0}, {5, 0, 6}, {5, 6, 11}, {5, 11, 9}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 5, 1}, {4, 6, 11}, {4, 11, 9}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 0, 6}, {8, 6, 11}, {8, 11, 9}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 6, 11}, {4, 11, 9}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 4, 5}, {0, 5, 1}, {6, 11, 2}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 5, 1}, {6, 11, 2}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 8, 0}, {6, 11, 2}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 11, 2}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{7, 6, 2}, {7, 2, 3}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{7, 6, 0}, {7, 0, 8}, {4, 2, 3}, {3, 7, 8}, {3, 8, 4},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{1, 7, 6}, {2, 3, 5}, {2, 5, 8}, {8, 1, 6}, {8, 6, 2},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 0, 1}, {6, 1, 7}, {5, 4, 2}, {5, 2, 3}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{7, 6, 4}, {7, 4, 9}, {7, 9, 3}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{7, 6, 0}, {7, 0, 8}, {7, 8, 9}, {7, 9, 3}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 4, 8}, {6, 8, 1}, {6, 1, 7}, {5, 9, 3}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 0, 1}, {6, 1, 7}, {5, 9, 3}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{5, 7, 6}, {5, 6, 2}, {5, 2, 9}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 0, 8}, {6, 8, 5}, {6, 5, 7}, {4, 2, 9}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 1, 7}, {8, 7, 6}, {8, 6, 2}, {8, 2, 9}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 0, 1}, {6, 1, 7}, {4, 2, 9}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 4, 5}, {6, 5, 7}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 0, 8}, {6, 8, 5}, {6, 5, 7}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 4, 8}, {6, 8, 1}, {6, 1, 7}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{6, 0, 1}, {6, 1, 7}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{7, 10, 0}, {7, 0, 2}, {7, 2, 3}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{7, 10, 8}, {7, 8, 4}, {7, 4, 2}, {7, 2, 3}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 1, 7}, {5, 8, 0}, {5, 0, 2}, {5, 2, 3}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 1, 7}, {5, 4, 2}, {5, 2, 3}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{7, 10, 0}, {7, 0, 4}, {7, 4, 9}, {7, 9, 3}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{7, 10, 8}, {7, 8, 9}, {7, 9, 3}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 8, 0}, {10, 1, 7}, {5, 9, 3}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 1, 7}, {5, 9, 3}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{5, 7, 10}, {5, 10, 0}, {5, 0, 2}, {5, 2, 9}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 8, 5}, {10, 5, 7}, {4, 2, 9}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 1, 7}, {8, 0, 2}, {8, 2, 9}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 1, 7}, {4, 2, 9}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 0, 4}, {10, 4, 5}, {10, 5, 7}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 8, 5}, {10, 5, 7}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 8, 0}, {10, 1, 7}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 1, 7}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{1, 10, 6}, {1, 6, 2}, {1, 2, 3}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 10, 6}, {1, 8, 4}, {1, 4, 2}, {1, 2, 3}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{5, 8, 10}, {5, 10, 6}, {5, 6, 2}, {5, 2, 3}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 10, 6}, {5, 4, 2}, {5, 2, 3}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{1, 10, 6}, {1, 6, 4}, {1, 4, 9}, {1, 9, 3}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 10, 6}, {1, 8, 9}, {1, 9, 3}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 8, 10}, {4, 10, 6}, {5, 9, 3}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 10, 6}, {5, 9, 3}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{5, 1, 10}, {5, 10, 6}, {5, 6, 2}, {5, 2, 9}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 10, 6}, {8, 5, 1}, {4, 2, 9}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 10, 6}, {8, 6, 2}, {8, 2, 9}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 10, 6}, {4, 2, 9}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{10, 6, 4}, {10, 4, 5}, {10, 5, 1}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 10, 6}, {8, 5, 1}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 8, 10}, {4, 10, 6}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 10, 6}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{1, 0, 2}, {1, 2, 3}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{1, 8, 4}, {1, 4, 2}, {1, 2, 3}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{5, 8, 0}, {5, 0, 2}, {5, 2, 3}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{5, 4, 2}, {5, 2, 3}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{1, 0, 4}, {1, 4, 9}, {1, 9, 3}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{1, 8, 9}, {1, 9, 3}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 8, 0}, {5, 9, 3}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{5, 9, 3}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{5, 1, 0}, {5, 0, 2}, {5, 2, 9}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 5, 1}, {4, 2, 9}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 0, 2}, {8, 2, 9}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 2, 9}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 4, 5}, {0, 5, 1}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{8, 5, 1}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{4, 8, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}},
	{{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
	 {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}}
};
