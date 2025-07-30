@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

set "__STRING__="
set NUMERR=0

chcp

call :TEST 001 ""
call :TEST 002 
call :TEST 003 
call :TEST 004 
call :TEST 005 
call :TEST 006 
call :TEST 007 
call :TEST 008 
call :TEST 009 "	"
call :TEST 010
call :TEST 011 ""
call :TEST 012 ""
call :TEST 013
call :TEST 014 
call :TEST 015 
call :TEST 016 
call :TEST 017 
call :TEST 018 
call :TEST 019 
call :TEST 020 
call :TEST 021 
call :TEST 022 
call :TEST 023 
call :TEST 024 
call :TEST 025 

set __STRING__=^

call :TEST 026
call :TEST 027 
call :TEST 028 
call :TEST 029 
call :TEST 030 
call :TEST 031 
call :TEST 032 " "
call :TEST 033 "!"
set __STRING__=^"
call :TEST 034
call :TEST 035 "#"
call :TEST 036 "$"
call :TEST 037 "%%%%"
call :TEST 038 "&"
call :TEST 039 "'"
call :TEST 040 "("
call :TEST 041 ")"
call :TEST 042 "*"
call :TEST 043 "+-"
call :TEST 043 "+"
call :TEST 044 ","
call :TEST 045 "-"
call :TEST 046 "."
call :TEST 047 "/"
call :TEST 048 "0"
call :TEST 049 "1"
call :TEST 050 "2"
call :TEST 051 "3"
call :TEST 052 "4"
call :TEST 053 "5"
call :TEST 054 "6"
call :TEST 055 "7"
call :TEST 056 "8"
call :TEST 057 "9"
call :TEST 058 ":"
call :TEST 059 ";"
call :TEST 060 "<"
call :TEST 061 "="
call :TEST 062 ">"
call :TEST 063 "?"
call :TEST 064 "@"
call :TEST 065 "A"
call :TEST 066 "B"
call :TEST 067 "C"
call :TEST 068 "D"
call :TEST 069 "E"
call :TEST 070 "F"
call :TEST 071 "G"
call :TEST 072 "H"
call :TEST 073 "I"
call :TEST 074 "J"
call :TEST 075 "K"
call :TEST 076 "L"
call :TEST 077 "M"
call :TEST 078 "N"
call :TEST 079 "O"
call :TEST 080 "P"
call :TEST 081 "Q"
call :TEST 082 "R"
call :TEST 083 "S"
call :TEST 084 "T"
call :TEST 085 "U"
call :TEST 086 "V"
call :TEST 087 "W"
call :TEST 088 "X"
call :TEST 089 "Y"
call :TEST 090 "Z"
call :TEST 091 "["
call :TEST 092 "\"
call :TEST 093 "]"
set "__STRING__=^"
call :TEST 094
call :TEST 095 "_"
call :TEST 096 "`"
call :TEST 097 "a"
call :TEST 098 "b"
call :TEST 099 "c"
call :TEST 100 "d"
call :TEST 101 "e"
call :TEST 102 "f"
call :TEST 103 "g"
call :TEST 104 "h"
call :TEST 105 "i"
call :TEST 106 "j"
call :TEST 107 "k"
call :TEST 108 "l"
call :TEST 109 "m"
call :TEST 110 "n"
call :TEST 111 "o"
call :TEST 112 "p"
call :TEST 113 "q"
call :TEST 114 "r"
call :TEST 115 "s"
call :TEST 116 "t"
call :TEST 117 "u"
call :TEST 118 "v"
call :TEST 119 "w"
call :TEST 120 "x"
call :TEST 121 "y"
call :TEST 122 "z"
call :TEST 123 "{"
call :TEST 124 "|"
call :TEST 125 "}"
call :TEST 126 "~"
call :TEST 127 ""
call :TEST 128 "Ђ"
call :TEST 129 "Ѓ"
call :TEST 130 "‚"
call :TEST 131 "ѓ"
call :TEST 132 "„"
call :TEST 133 "…"
call :TEST 134 "†"
call :TEST 135 "‡"
call :TEST 136 "€"
call :TEST 137 "‰"
call :TEST 138 "Љ"
call :TEST 139 "‹"
call :TEST 140 "Њ"
call :TEST 141 "Ќ"
call :TEST 142 "Ћ"
call :TEST 143 "Џ"
call :TEST 144 "ђ"
call :TEST 145 "‘"
call :TEST 146 "’"
call :TEST 147 "“"
call :TEST 148 "”"
call :TEST 149 "•"
call :TEST 150 "–"
call :TEST 151 "—"
call :TEST 152 ""
call :TEST 153 "™"
call :TEST 154 "љ"
call :TEST 155 "›"
call :TEST 156 "њ"
call :TEST 157 "ќ"
call :TEST 158 "ћ"
call :TEST 159 "џ"
call :TEST 160 " "
call :TEST 161 "Ў"
call :TEST 162 "ў"
call :TEST 163 "Ј"
call :TEST 164 "¤"
call :TEST 165 "Ґ"
call :TEST 166 "¦"
call :TEST 167 "§"
call :TEST 168 "Ё"
call :TEST 169 "©"
call :TEST 170 "Є"
call :TEST 171 "«"
call :TEST 172 "¬"
call :TEST 173 "­"
call :TEST 174 "®"
call :TEST 175 "Ї"
call :TEST 176 "°"
call :TEST 177 "±"
call :TEST 178 "І"
call :TEST 179 "і"
call :TEST 180 "ґ"
call :TEST 181 "µ"
call :TEST 182 "¶"
call :TEST 183 "·"
call :TEST 184 "ё"
call :TEST 185 "№"
call :TEST 186 "є"
call :TEST 187 "»"
call :TEST 188 "ј"
call :TEST 189 "Ѕ"
call :TEST 190 "ѕ"
call :TEST 191 "ї"
call :TEST 192 "А"
call :TEST 193 "Б"
call :TEST 194 "В"
call :TEST 195 "Г"
call :TEST 196 "Д"
call :TEST 197 "Е"
call :TEST 198 "Ж"
call :TEST 199 "З"
call :TEST 200 "И"
call :TEST 201 "Й"
call :TEST 202 "К"
call :TEST 203 "Л"
call :TEST 204 "М"
call :TEST 205 "Н"
call :TEST 206 "О"
call :TEST 207 "П"
call :TEST 208 "Р"
call :TEST 209 "С"
call :TEST 210 "Т"
call :TEST 211 "У"
call :TEST 212 "Ф"
call :TEST 213 "Х"
call :TEST 214 "Ц"
call :TEST 215 "Ч"
call :TEST 216 "Ш"
call :TEST 217 "Щ"
call :TEST 218 "Ъ"
call :TEST 219 "Ы"
call :TEST 220 "Ь"
call :TEST 221 "Э"
call :TEST 222 "Ю"
call :TEST 223 "Я"
call :TEST 224 "а"
call :TEST 225 "б"
call :TEST 226 "в"
call :TEST 227 "г"
call :TEST 228 "д"
call :TEST 229 "е"
call :TEST 230 "ж"
call :TEST 231 "з"
call :TEST 232 "и"
call :TEST 233 "й"
call :TEST 234 "к"
call :TEST 235 "л"
call :TEST 236 "м"
call :TEST 237 "н"
call :TEST 238 "о"
call :TEST 239 "п"
call :TEST 240 "р"
call :TEST 241 "с"
call :TEST 242 "т"
call :TEST 243 "у"
call :TEST 244 "ф"
call :TEST 245 "х"
call :TEST 246 "ц"
call :TEST 247 "ч"
call :TEST 248 "ш"
call :TEST 249 "щ"
call :TEST 250 "ъ"
call :TEST 251 "ы"
call :TEST 252 "ь"
call :TEST 253 "э"
call :TEST 254 "ю"
call :TEST 255 "я"

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 1

chcp

echo Errors: %NUMERR%
echo Time spent: %TIME_INTS%.%TIME_FRACS% secs
echo;

exit /b 0

:TEST
set "ASCII_CODE_REF_STR=%~1"
if "%ASCII_CODE_REF_STR:~2,1%" == "" set ASCII_CODE_REF_STR=0%ASCII_CODE_REF_STR%
if "%ASCII_CODE_REF_STR:~2,1%" == "" set ASCII_CODE_REF_STR=0%ASCII_CODE_REF_STR%

call "%%CONTOOLS_ROOT%%/std/asc-utf.bat" %%2

set "ASCII_CODE_STR=%ERRORLEVEL%"
if "%ASCII_CODE_STR:~2,1%" == "" set ASCII_CODE_STR=0%ASCII_CODE_STR%
if "%ASCII_CODE_STR:~2,1%" == "" set ASCII_CODE_STR=0%ASCII_CODE_STR%

if "%ASCII_CODE_REF_STR%" == "%ASCII_CODE_STR%" (
  <nul set /P =OK : ^<%ASCII_CODE_REF_STR%^>
) else (
  set /A NUMERR-=-1
  <nul set /P =ERR: ^<%ASCII_CODE_REF_STR%^>
)

if defined __STRING__ (
  call "%%CONTOOLS_ROOT%%/std/set_var.bat" CHAR __STRING__
) else set "CHAR=%~2"

if defined CHAR (
  call "%%CONTOOLS_ROOT%%/std/echo_var.bat" CHAR "[%ASCII_CODE_STR%] |" "|"
) else echo;[---] ^| ^|

set "__STRING__="
