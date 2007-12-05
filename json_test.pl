/*  $Id$

    Part of SWI-Prolog

    Author:        Jan Wielemaker
    E-mail:        wielemak@science.uva.nl
    WWW:           http://www.swi-prolog.org
    Copyright (C): 1985-2007, University of Amsterdam

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    As a special exception, if you link this library with other files,
    compiled with a Free Software compiler, to produce an executable, this
    library does not by itself cause the resulting executable to be covered
    by the GNU General Public License. This exception does not however
    invalidate any other reasons why the executable file might be covered by
    the GNU General Public License.
*/

:- module(json_test,
	  [ json_test/0
	  ]).
:- asserta(user:file_search_path(foreign, '.')).
:- asserta(user:file_search_path(foreign, '../clib')).
:- asserta(user:file_search_path(library, '../plunit')).
:- asserta(user:file_search_path(library, '../clib')).

:- use_module(library(plunit)).
:- use_module(json).
:- use_module(json_convert).

json_test :-
	run_tests([ json_read,
		    json_convert
		  ]).

:- begin_tests(json_read).

test(true, X == @(true)) :-
	atom_json_term(true, X, []).
test(true, X == true) :-
	atom_json_term(true, X, [true(true)]).

test(string, X == hello) :-
	atom_json_term('"hello"', X, []).
test(string, X == '\\\b\f\n\r\t') :-
	atom_json_term('"\\\\\\b\\f\\n\\r\\t"', X, []).
test(string, X == '\u1234') :-
	atom_json_term('"\\u1234"', X, []).

test(int, X == 42) :-
	atom_json_term('42', X, []).
test(int, X == -42) :-
	atom_json_term('-42', X, []).

test(float, X == 3.14) :-
	atom_json_term('3.14', X, []).
test(float, X == -3.14) :-
	atom_json_term('-3.14', X, []).
test(float, X == 1000.0) :-
	atom_json_term('1e3', X, []).
test(float, X == 0.001) :-
	atom_json_term('1e-3', X, []).

test(empty, X == object([])) :-
	atom_json_term({}, X, []).
test(empty, X == object([])) :-
	atom_json_term('  {  } ', X, []).
test(empty, X == object([])) :-
	atom_json_term('  {\n//comment\n} ', X, []).


:- end_tests(json_read).


		 /*******************************
		 *	      CONVERT		*
		 *******************************/

:- begin_tests(json_convert).

:- json_object
	point(x:integer, y:integer),
	tpoint(x:integer, y:integer)+[type=point],
	fpoint(x:float, y:float).

test(pt2json, JSON == object([x=25,y=50])) :-
	prolog_to_json(point(25,50), JSON).
test(pt2json, JSON == object([x=25,y=50,type=point])) :-
	prolog_to_json(tpoint(25,50), JSON).

test(json2pt, X == point(25,50)) :-
	json_to_prolog(object([x=25,y=50]), X).
test(json2pt, X == point(25,50)) :-
	json_to_prolog(object([y=50,x=25]), X).
test(json2pt, X == fpoint(25.1,50.0)) :-
	json_to_prolog(object([y=50.0,x=25.1]), X).
test(json2pt, fail) :-
	json_to_prolog(object([y=50,x=25.1]), _).
test(json2pt, X == tpoint(25,50)) :-
	json_to_prolog(object([x=25,y=50,type=point]), X).

:- end_tests(json_convert).
