%
% Drosk's prolog build system
%
% In order to add a build target:
%  - write a prolog file containing it's definition
%  - include that prolog file here
%  - add the name of the target to the 'targets' predicate
%

:- use_module(library(filesex)).
:- [boot/main, kernel/main, util/bfsgen/main].

targets([boot, kernel, bfsgen]).

% The top level target predicates
build :- targets(Ts), map(build, Ts), writeln('ok.').
clean :- targets(Ts), map(clean, Ts), writeln('ok.').

% The predicates for target operations, do dep check first
build(T) :-
	\+ call(T, build_dep).
build(T) :-
	call(T, build_dep),
	lwrite(['building ', T]),
	call(T, build).

clean(T) :-
	\+ call(T, clean_dep).
clean(T) :-
	call(T, clean_dep),
	lwrite(['cleaning ', T]),
	call(T, clean).

% The rule used to build NASM assembly files
nasm(build_dep, Out, In, _, Extra) :-
	remake3(Out, In, Extra).

nasm(build, Out, In, Args, _) :-
	lwrite(['  nasm ', Out]),
	lshell(['nasm -o ', Out, ' ', In, ' ', Args]).

nasm(clean_dep, Out, _, _, _) :-
	exists_file(Out).

nasm(clean, Out, _, _, _) :-
	lwrite([' rm ', Out]),
	rm(Out).

% The rule used to build C files
cc(build_dep, Out, In, _, Extra) :-
	remake3(Out, In, Extra).

cc(build, Out, In, Args, _) :-
	lwrite(['  cc ', Out]),
	lshell(['cc -o ', Out, ' ', In, ' ', Args]).

cc(clean_dep, Out, _, _, _) :-
	exists_file(Out).

cc(clean, Out, _, _, _) :-
	lwrite([' rm ', Out]),
	rm(Out).

% calls a predicate for every element in a list
map(_, []).
map(F, [X | Xs]) :-
	call(F, X),
	map(F, Xs).

% Adds a prefix to each string in the list
prefix(_, [], []).
prefix(Prefix, [X | Xs], [Y | Ys]) :-
	string_concat(Prefix, X, Y),
	prefix(Prefix, Xs, Ys).

% Adds a suffix to each string in the list
suffix(_, [], []).
suffix(Suffix, [X | Xs], [Y | Ys]) :-
	string_concat(Suffix, X, Y),
	suffix(Suffix, Xs, Ys).

% Concatenates a list into a string
concat([], '').
concat([Prefix | Ls], Str) :-
	concat(Ls, Suffix),
	string_concat(Prefix, Suffix, Str).

% Convience function that acts like write/1, but concats list first
lwrite(Ls) :-
	concat(Ls, Cmd),
	writeln(Cmd).

% Convience function that acts like shell/1, but concats list first
lshell(Ls) :-
	concat(Ls, Cmd),
	shell(Cmd).

% This will return true if What needs to be remade with respect to the given file list
remake(Obj, _) :-
	\+ exists(Obj).
remake(Obj, [D | Deps]) :-
	\+ exists(D);
	newer(D, Obj);
	remake(Obj, Deps).

% Convience predicate that wraps to remake
remake3(Out, In, Extra) :-
	append(Extra, [In], Deps),
	remake(Out, Deps).

% True if file A is newer (modified) than file B
newer(A, B) :-
	set_time_file(A, [modified(C)], []),
	set_time_file(B, [modified(D)], []),
	C > D.

% Returns true if F is a file or directory that exists
exists(F) :- exists_file(F).
exists(F) :- exists_directory(F).
