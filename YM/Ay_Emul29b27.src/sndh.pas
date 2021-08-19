unit sndh;

{$mode objfpc}{$H+}

interface

uses
 Classes, SysUtils, {ay,} sometypes;

type
 TPlayGen = (GenVBL,GenTA,GenTB,GenTC,GenTD);

function sndh_UnpackFile(const FileName:string;var SNDHBuffer:TArrayOfByte):boolean;
function sndh_ExtractTextInfo(const SNDHBuffer:TArrayOfByte;
   var COMM,TITL,RIPP,CONV,YEAR,OtherShortDesc:string;
   var NumberOfSongs,CurrentSong,PlayFreq:integer;var PlayGen:TPlayGen;
   var PlayTimes:TArrayOfInteger;var SongNames:TArrayOfString;var MuMo:boolean):boolean;

implementation

{$ifdef Dbg}
uses
 Main;
{$endif}

const
 MAX_HEADER = 200;
 sndh_ICE  = $21454349; {ICE!}

 //MOTOROLA byte order
 sndh_SNDH = $48444e53; {HDNS}
 sndh_HDNS = $534e4448; {SNDH}
 sndh_COMM = $4d4d4f43; {MMOC}
 sndh_TITL = $4c544954; {LTIT}
 sndh_RIPP = $50504952; {PPIR}
 sndh_CONV = $564e4f43; {VNOC}
 sndh_YEAR = $52414559; {RAEY}
 sndh_nn   = $2323;     {##}
 sndh_VBL  = $5621;     {V!}
 sndh_TA   = $4154;     {AT}
 sndh_TB   = $4254;     {BT}
 sndh_TC   = $4354;     {CT}
 sndh_TD   = $4454;     {DT}
 sndh_TIME = $454d4954; {EMIT}
 sndh_MuMo = $6F4D754D; {oMuM}
 sndh__nSN = $4E532321; {NS#!} //strange error in sndhv21.txt
 sndh_n_SN = $4E532123; {NS!#} //strange error in sndhv21.txt
 sndh__nST = $54532321; {TS#!} //found in sndh45lf\BB\TEC_Demo.sndh
 sndh_n_   = $2123;     {!#}   //strange error in sndhv21.txt
 sndh__n   = $2321;     {#!}   //strange error in sndhv21.txt

 function AtariCPToUtf8(const s:string):string;
 (* Atari ST code page
 Get from http://www.ascii.ca/atarist.htm and wiki
 Dec 	Hex 	Char 	Name
 32 	20 	  	SPACE
 33 	21 	! 	EXCLAMATION MARK
 34 	22 	" 	QUOTATION MARK
 35 	23 	# 	NUMBER SIGN
 36 	24 	$ 	DOLLAR SIGN
 37 	25 	% 	PERCENT SIGN
 38 	26 	& 	AMPERSAND
 39 	27 	' 	APOSTROPHE
 40 	28 	( 	LEFT PARENTHESIS
 41 	29 	) 	RIGHT PARENTHESIS
 42 	2A 	* 	ASTERISK
 43 	2B 	+ 	PLUS SIGN
 44 	2C 	, 	COMMA
 45 	2D 	- 	HYPHEN-MINUS
 46 	2E 	. 	FULL STOP
 47 	2F 	/ 	SOLIDUS
 48 	30 	0 	DIGIT ZERO
 49 	31 	1 	DIGIT ONE
 50 	32 	2 	DIGIT TWO
 51 	33 	3 	DIGIT THREE
 52 	34 	4 	DIGIT FOUR
 53 	35 	5 	DIGIT FIVE
 54 	36 	6 	DIGIT SIX
 55 	37 	7 	DIGIT SEVEN
 56 	38 	8 	DIGIT EIGHT
 57 	39 	9 	DIGIT NINE
 58 	3A 	: 	COLON
 59 	3B 	; 	SEMICOLON
 60 	3C 	< 	LESS-THAN SIGN
 61 	3D 	= 	EQUALS SIGN
 62 	3E 	> 	GREATER-THAN SIGN
 63 	3F 	? 	QUESTION MARK
 64 	40 	@ 	COMMERCIAL AT
 65 	41 	A 	LATIN CAPITAL LETTER A
 66 	42 	B 	LATIN CAPITAL LETTER B
 67 	43 	C 	LATIN CAPITAL LETTER C
 68 	44 	D 	LATIN CAPITAL LETTER D
 69 	45 	E 	LATIN CAPITAL LETTER E
 70 	46 	F 	LATIN CAPITAL LETTER F
 71 	47 	G 	LATIN CAPITAL LETTER G
 72 	48 	H 	LATIN CAPITAL LETTER H
 73 	49 	I 	LATIN CAPITAL LETTER I
 74 	4A 	J 	LATIN CAPITAL LETTER J
 75 	4B 	K 	LATIN CAPITAL LETTER K
 76 	4C 	L 	LATIN CAPITAL LETTER L
 77 	4D 	M 	LATIN CAPITAL LETTER M
 78 	4E 	N 	LATIN CAPITAL LETTER N
 79 	4F 	O 	LATIN CAPITAL LETTER O
 80 	50 	P 	LATIN CAPITAL LETTER P
 81 	51 	Q 	LATIN CAPITAL LETTER Q
 82 	52 	R 	LATIN CAPITAL LETTER R
 83 	53 	S 	LATIN CAPITAL LETTER S
 84 	54 	T 	LATIN CAPITAL LETTER T
 85 	55 	U 	LATIN CAPITAL LETTER U
 86 	56 	V 	LATIN CAPITAL LETTER V
 87 	57 	W 	LATIN CAPITAL LETTER W
 88 	58 	X 	LATIN CAPITAL LETTER X
 89 	59 	Y 	LATIN CAPITAL LETTER Y
 90 	5A 	Z 	LATIN CAPITAL LETTER Z
 91 	5B 	[ 	LEFT SQUARE BRACKET
 92 	5C 	\ 	REVERSE SOLIDUS
 93 	5D 	] 	RIGHT SQUARE BRACKET
 94 	5E 	^ 	CIRCUMFLEX ACCENT
 95 	5F 	_ 	LOW LINE
 96 	60 	` 	GRAVE ACCENT
 97 	61 	a 	LATIN SMALL LETTER A
 98 	62 	b 	LATIN SMALL LETTER B
 99 	63 	c 	LATIN SMALL LETTER C
 100 	64 	d 	LATIN SMALL LETTER D
 101 	65 	e 	LATIN SMALL LETTER E
 102 	66 	f 	LATIN SMALL LETTER F
 103 	67 	g 	LATIN SMALL LETTER G
 104 	68 	h 	LATIN SMALL LETTER H
 105 	69 	i 	LATIN SMALL LETTER I
 106 	6A 	j 	LATIN SMALL LETTER J
 107 	6B 	k 	LATIN SMALL LETTER K
 108 	6C 	l 	LATIN SMALL LETTER L
 109 	6D 	m 	LATIN SMALL LETTER M
 110 	6E 	n 	LATIN SMALL LETTER N
 111 	6F 	o 	LATIN SMALL LETTER O
 112 	70 	p 	LATIN SMALL LETTER P
 113 	71 	q 	LATIN SMALL LETTER Q
 114 	72 	r 	LATIN SMALL LETTER R
 115 	73 	s 	LATIN SMALL LETTER S
 116 	74 	t 	LATIN SMALL LETTER T
 117 	75 	u 	LATIN SMALL LETTER U
 118 	76 	v 	LATIN SMALL LETTER V
 119 	77 	w 	LATIN SMALL LETTER W
 120 	78 	x 	LATIN SMALL LETTER X
 121 	79 	y 	LATIN SMALL LETTER Y
 122 	7A 	z 	LATIN SMALL LETTER Z
 123 	7B 	{ 	LEFT CURLY BRACKET
 124 	7C 	| 	VERTICAL LINE
 125 	7D 	} 	RIGHT CURLY BRACKET
 126 	7E 	~ 	TILDE
 128 	80 	Ç 	LATIN CAPITAL LETTER C WITH CEDILLA
 129 	81 	ü 	LATIN SMALL LETTER U WITH DIAERESIS
 130 	82 	é 	LATIN SMALL LETTER E WITH ACUTE
 131 	83 	â 	LATIN SMALL LETTER A WITH CIRCUMFLEX
 132 	84 	ä 	LATIN SMALL LETTER A WITH DIAERESIS
 133 	85 	à 	LATIN SMALL LETTER A WITH GRAVE
 134 	86 	å 	LATIN SMALL LETTER A WITH RING ABOVE
 135 	87 	ç 	LATIN SMALL LETTER C WITH CEDILLA
 136 	88 	ê 	LATIN SMALL LETTER E WITH CIRCUMFLEX
 137 	89 	ë 	LATIN SMALL LETTER E WITH DIAERESIS
 138 	8A 	è 	LATIN SMALL LETTER E WITH GRAVE
 139 	8B 	ï 	LATIN SMALL LETTER I WITH DIAERESIS
 140 	8C 	î 	LATIN SMALL LETTER I WITH CIRCUMFLEX
 141 	8D 	ì 	LATIN SMALL LETTER I WITH GRAVE
 142 	8E 	Ä 	LATIN CAPITAL LETTER A WITH DIAERESIS
 143 	8F 	Å 	LATIN CAPITAL LETTER A WITH RING ABOVE
 144 	90 	É 	LATIN CAPITAL LETTER E WITH ACUTE
 145 	91 	æ 	LATIN SMALL LETTER AE
 146 	92 	Æ 	LATIN CAPITAL LETTER AE
 147 	93 	ô 	LATIN SMALL LETTER O WITH CIRCUMFLEX
 148 	94 	ö 	LATIN SMALL LETTER O WITH DIAERESIS
 149 	95 	ò 	LATIN SMALL LETTER O WITH GRAVE
 150 	96 	û 	LATIN SMALL LETTER U WITH CIRCUMFLEX
 151 	97 	ù 	LATIN SMALL LETTER U WITH GRAVE
 152 	98 	ÿ 	LATIN SMALL LETTER Y WITH DIAERESIS
 153 	99 	Ö 	LATIN CAPITAL LETTER O WITH DIAERESIS
 154 	9A 	Ü 	LATIN CAPITAL LETTER U WITH DIAERESIS
 155 	9B 	¢ 	CENT SIGN
 156 	9C 	£ 	POUND SIGN
 157 	9D 	¥ 	YEN SIGN
 158 	9E 	ß 	LATIN SMALL LETTER SHARP S
 159 	9F 	ƒ 	LATIN SMALL LETTER F WITH HOOK
 160 	A0 	á 	LATIN SMALL LETTER A WITH ACUTE
 161 	A1 	í 	LATIN SMALL LETTER I WITH ACUTE
 162 	A2 	ó 	LATIN SMALL LETTER O WITH ACUTE
 163 	A3 	ú 	LATIN SMALL LETTER U WITH ACUTE
 164 	A4 	ñ 	LATIN SMALL LETTER N WITH TILDE
 165 	A5 	Ñ 	LATIN CAPITAL LETTER N WITH TILDE
 166 	A6 	ª 	FEMININE ORDINAL INDICATOR
 167 	A7 	º 	MASCULINE ORDINAL INDICATOR
 168 	A8 	¿ 	INVERTED QUESTION MARK
 169 	A9 	⌐ 	REVERSED NOT SIGN
 170 	AA 	¬ 	NOT SIGN
 171 	AB 	½ 	VULGAR FRACTION ONE HALF
 172 	AC 	¼ 	VULGAR FRACTION ONE QUARTER
 173 	AD 	¡ 	INVERTED EXCLAMATION MARK
 174 	AE 	« 	LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
 175 	AF 	» 	RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
 176 	B0 	ã 	LATIN SMALL LETTER A WITH TILDE
 177 	B1 	õ 	LATIN SMALL LETTER O WITH TILDE
 178 	B2 	Ø 	LATIN CAPITAL LETTER O WITH STROKE
 179 	B3 	ø 	LATIN SMALL LETTER O WITH STROKE
 180 	B4 	œ 	LATIN SMALL LIGATURE OE
 181 	B5 	Œ 	LATIN CAPITAL LIGATURE OE
 182 	B6 	À 	LATIN CAPITAL LETTER A WITH GRAVE
 183 	B7 	Ã 	LATIN CAPITAL LETTER A WITH TILDE
 184 	B8 	Õ 	LATIN CAPITAL LETTER O WITH TILDE
 185 	B9 	¨ 	DIAERESIS
 186 	BA 	´ 	ACUTE ACCENT
 187 	BB 	† 	DAGGER
 188 	BC 	¶ 	PILCROW SIGN
 189 	BD 	© 	COPYRIGHT SIGN
 190 	BE 	® 	REGISTERED SIGN
 191 	BF 	™ 	TRADE MARK SIGN
 192 	C0 	ĳ 	LATIN SMALL LIGATURE IJ
 193 	C1 	Ĳ 	LATIN CAPITAL LIGATURE IJ
 194 	C2 	א 	HEBREW LETTER ALEF
 195 	C3 	ב 	HEBREW LETTER BET
 196 	C4 	ג 	HEBREW LETTER GIMEL
 197 	C5 	ד 	HEBREW LETTER DALET
 198 	C6 	ה 	HEBREW LETTER HE
 199 	C7 	ו 	HEBREW LETTER VAV
 200 	C8 	ז 	HEBREW LETTER ZAYIN
 201 	C9 	ח 	HEBREW LETTER HET
 202 	CA 	ט 	HEBREW LETTER TET
 203 	CB 	י 	HEBREW LETTER YOD
 204 	CC 	כ 	HEBREW LETTER KAF
 205 	CD 	ל 	HEBREW LETTER LAMED
 206 	CE 	מ 	HEBREW LETTER MEM
 207 	CF 	נ 	HEBREW LETTER NUN
 208 	D0 	ס 	HEBREW LETTER SAMEKH
 209 	D1 	ע 	HEBREW LETTER AYIN
 210 	D2 	פ 	HEBREW LETTER PE
 211 	D3 	צ 	HEBREW LETTER TSADI
 212 	D4 	ק 	HEBREW LETTER QOF
 213 	D5 	ר 	HEBREW LETTER RESH
 214 	D6 	ש 	HEBREW LETTER SHIN
 215 	D7 	ת 	HEBREW LETTER TAV
 216 	D8 	ן 	HEBREW LETTER FINAL NUN
 217 	D9 	ך 	HEBREW LETTER FINAL KAF
 218 	DA 	ם 	HEBREW LETTER FINAL MEM
 219 	DB 	ף 	HEBREW LETTER FINAL PE
 220 	DC 	ץ 	HEBREW LETTER FINAL TSADI
 221 	DD 	§ 	SECTION SIGN
 222 	DE 	∧ 	LOGICAL AND
 223 	DF 	∞ 	INFINITY
 224 	E0 	α 	GREEK SMALL LETTER ALPHA
 225 	E1 	β 	GREEK SMALL LETTER BETA
 226 	E2 	Γ 	GREEK CAPITAL LETTER GAMMA
 227 	E3 	π 	GREEK SMALL LETTER PI
 228 	E4 	Σ 	GREEK CAPITAL LETTER SIGMA
 229 	E5 	σ 	GREEK SMALL LETTER SIGMA
 230 	E6 	µ 	MICRO SIGN
 231 	E7 	τ 	GREEK SMALL LETTER TAU
 232 	E8 	Φ 	GREEK CAPITAL LETTER PHI
 233 	E9 	Θ 	GREEK CAPITAL LETTER THETA
 234 	EA 	Ω 	GREEK CAPITAL LETTER OMEGA
 235 	EB 	δ 	GREEK SMALL LETTER DELTA
 236 	EC 	∮ 	CONTOUR INTEGRAL
 237 	ED 	φ 	GREEK SMALL LETTER PHI
 238 	EE 	ε 	GREEK SMALL LETTER EPSILON
 239 	EF 	∩ 	INTERSECTION
 240 	F0 	≡ 	IDENTICAL TO
 241 	F1 	± 	PLUS-MINUS SIGN
 242 	F2 	≥ 	GREATER-THAN OR EQUAL TO
 243 	F3 	≤ 	LESS-THAN OR EQUAL TO
 244 	F4 	⌠ 	TOP HALF INTEGRAL
 245 	F5 	⌡ 	BOTTOM HALF INTEGRAL
 246 	F6 	÷ 	DIVISION SIGN
 247 	F7 	≈ 	ALMOST EQUAL TO
 248 	F8 	° 	DEGREE SIGN
 249 	F9 	∙ 	BULLET OPERATOR
 250 	FA 	· 	MIDDLE DOT
 251 	FB 	√ 	SQUARE ROOT
 252 	FC 	ⁿ 	SUPERSCRIPT LATIN SMALL LETTER N
 253 	FD 	² 	SUPERSCRIPT TWO
 254 	FE 	³ 	SUPERSCRIPT THREE
 255 	FF 	¯ 	MACRON
 *)
 const
  AtariSTCP:array[32..255] of string =
   (' ','!','"','#','$','%','&','''','(',')','*','+','0','-','.','/',
    '0','1','2','3','4','5','6','7','8','9',':',';','<','=','>','?',
    '@','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O',
    'P','Q','R','S','T','U','V','W','X','Y','Z','[','\',']','^','_',
    '`','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o',
    'p','q','r','s','t','u','v','w','x','y','z','{','|','}','~','⌂',
    'Ç','ü','é','â','ä','à','å','ç','ê','ë','è','ï','î','ì','Ä','Å',
    'É','æ','Æ','ô','ö','ò','û','ù','ÿ','Ö','Ü','¢','£','¥','ß','ƒ',
    'á','í','ó','ú','ñ','Ñ','ª','º','¿','⌐','¬','½','¼','¡','«','»',
    'ã','õ','Ø','ø','œ','Œ','À','Ã','Õ','¨','´','†','¶','©','®','™',
    'ĳ','Ĳ','א','ב','ג','ד','ה','ו','ז','ח','ט','י','כ','ל','מ','נ',
    'ס','ע','פ','צ','ק','ר','ש','ת','ן','ך','ם','ף','ץ','§','∧','∞',
    'α','β','Γ','π','Σ','σ','µ','τ','Φ','Θ','Ω','δ','∮','φ','ε','∩',
    '≡','±','≥','≤','⌠','⌡','÷','≈','°','∙','·','√','ⁿ','²','³','¯');
 var
  i:integer;
 begin
  Result := '';
  for i := 1 to Length(s) do
   if Ord(s[i]) >= 32 then
    Result := Result + AtariSTCP[Ord(s[i])]
   else
    Result := Result + '_';
 end;

function sndh_UnpackFile(const FileName:string;var SNDHBuffer:TArrayOfByte):boolean;
const
 direct_tab:array[0..4] of record
  NumberOfBits,BitsMaxValue,AdditionToBitsValue:integer
 end =
  ((NumberOfBits:15;BitsMaxValue:$7fff;AdditionToBitsValue:270),
   (NumberOfBits: 8;BitsMaxValue:$00ff;AdditionToBitsValue: 15),
   (NumberOfBits: 3;BitsMaxValue:$0007;AdditionToBitsValue:  8),
   (NumberOfBits: 2;BitsMaxValue:$0003;AdditionToBitsValue:  5),
   (NumberOfBits: 2;BitsMaxValue:$0003;AdditionToBitsValue:  2));
 length_tab:array[0..9] of shortint =
  (10,2,1,-1,-1,8,4,2,1,0);
 more_offset:array[0..2] of shortint =
  (12,5,8);
 more_offset2:array[0..2] of smallint =
  ($11f,-1,31);

var
 f:file;
 PackedSize,PI,UI:integer;
 BitGroup:smallint;
 CB:byte;
 PackedBuffer:array of byte;

function get_1_bit:integer;
var
 a:integer;
begin
if shortint(CB) < 0 then
 Result := 1
else
 Result := 0;
inc(CB,CB);
if CB = 0 then
 begin
  dec(PI);
  CB := PackedBuffer[PI];
  a := Result;
  if shortint(CB) < 0 then
   Result := 1
  else
   Result := 0;
  inc(CB,CB + a)
 end
end;

procedure get_N_bits(N:byte);
var
 a,b,i:integer;
begin
BitGroup := 0;
for i := 1 to N do
 begin
  if shortint(CB) < 0 then
   a := 1
  else
   a := 0;
  inc(CB,CB);
  if CB = 0 then
   begin
    dec(PI);
    CB := PackedBuffer[PI];
    b := a;
    if shortint(CB) < 0 then
     a := 1
    else
     a := 0;
    inc(CB,CB + b);
   end;
  inc(BitGroup,BitGroup + a);
 end;
end;

procedure normal_bytes;
var
 i,j,k:integer;
begin
repeat
if get_1_bit <> 0 then
 begin
  BitGroup := 1;
  if get_1_bit <> 0 then
   begin
    j := 5;
    for i := 0 to 4 do
     begin
      dec(j);
      get_N_bits(direct_tab[j].NumberOfBits);
      if direct_tab[j].BitsMaxValue <> BitGroup then break
     end;
    inc(BitGroup,direct_tab[j].AdditionToBitsValue)
   end;
  {copy_direct}
  dec(PI,BitGroup);
  dec(UI,BitGroup);
  Move(PackedBuffer[PI],SNDHBuffer[UI],BitGroup);
 end;
{test_if_end}
if UI > 0 then
 begin {strings}
  i := 4;
  repeat
   if get_1_bit = 0 then break;
   dec(i)
  until i = 0;
  BitGroup := 0;
  j := smallint(length_tab[i]);
  if j >= 0 then
   get_N_bits(j);
  k := length_tab[i + 5] + BitGroup;
  if k <> 0 then
   begin
    i := 2;
    repeat
     if get_1_bit = 0 then break;
     dec(i)
    until i = 0;
    get_N_bits(more_offset[i]);
    inc(BitGroup,more_offset2[i]);
    if BitGroup < 0 then
     dec(BitGroup,k);
   end
  else
   begin
   {get_offset_2}
    i := 6;
    j := -1;
    if get_1_bit <> 0 then
     begin
      i := 9;
      j := $3f;
     end;
    get_N_bits(i);
    inc(BitGroup,j);
   end;
  {depack_bytes}
  j := UI + k + BitGroup + 1;
  dec(UI);
  SNDHBuffer[UI] := SNDHBuffer[j];
  for i := 0 to k do
   begin
    dec(j);
    dec(UI);
    SNDHBuffer[UI] := SNDHBuffer[j];
   end;
 end;
until UI <= 0;
end;

var
 i,j,a,UnpackedSize:integer;
 k:word;
 l:smallint;
 m:packed record
  case Boolean of
  True:(m1,m2,m3,m4:word);
  False:(l1,h1,l2,h2,l3,h3,l4,h4:byte);
 end;

begin
AssignFile(f,FileName);
Reset(f,1);
BlockRead(f,i{%H-},4);
if i <> sndh_ICE then
 begin
  UnpackedSize := FileSize(f);
  SetLength(SNDHBuffer,UnpackedSize);
  PLongInt(@SNDHBuffer[0])^ := i;
  BlockRead(f,SNDHBuffer[4],int64(UnpackedSize) - 4);
  CloseFile(f);
  exit(True);
 end;
BlockRead(f,PackedSize{%H-},4);
PackedSize := SwapEndian(PackedSize);
if PackedSize > FileSize(f) then
 begin
  CloseFile(f);
  exit(False);
 end;
dec(PackedSize,12);
PI := PackedSize;
BlockRead(f,UnpackedSize,4);
UnpackedSize := SwapEndian(UnpackedSize);
UI := UnpackedSize;
SetLength(PackedBuffer,PackedSize);
BlockRead(f,PackedBuffer[0],PackedSize);
CloseFile(f);
SetLength(SNDHBuffer,UnpackedSize);
dec(PI);
CB := PackedBuffer[PI];
normal_bytes;
UI := UnpackedSize;
if get_1_bit <> 0 then
 begin
  //not tested begin
  {$IFDEF Dbg}
  DbgStr(#9'Not tested piece of ICE depacking code is used !!!');
  {$ENDIF Dbg}
  k := $f9f;
  if get_1_bit <> 0 then
   begin
    get_N_bits(16);
    k := BitGroup;
   end;
  {ice_00}
  for k := 0 to k do
   begin
    for i := 0 to 3 do
     begin
      dec(UI,2);
      l := PSmallInt(@SNDHBuffer[UI])^;
      for j := 0 to 3 do
       begin
        if l < 0 then
         a := 1
        else
         a := 0;
        inc(l,l);
        inc(m.m1,m.m1 + a);
        if l < 0 then
         a := 1
        else
         a := 0;
        inc(l,l);
        inc(m.m2,m.m2 + a);
        if l < 0 then
         a := 1
        else
         a := 0;
        inc(l,l);
        inc(m.m3,m.m3 + a);
        if l < 0 then
         a := 1
        else
         a := 0;
        inc(l,l);
        inc(m.m4,m.m4 + a);
       end
     end;
    SNDHBuffer[UI] := m.h1;
    SNDHBuffer[UI + 1] := m.l1;
    SNDHBuffer[UI + 2] := m.h2;
    SNDHBuffer[UI + 3] := m.l2;
    SNDHBuffer[UI + 4] := m.h3;
    SNDHBuffer[UI + 5] := m.l3;
    SNDHBuffer[UI + 6] := m.h4;
    SNDHBuffer[UI + 7] := m.l4;
   end;
  //not tested end
 end;
PackedBuffer := nil;
Result := True;
end;

function sndh_ExtractTextInfo(const SNDHBuffer:TArrayOfByte;
   var COMM,TITL,RIPP,CONV,YEAR,OtherShortDesc:string;
   var NumberOfSongs,CurrentSong,PlayFreq:integer;var PlayGen:TPlayGen;
   var PlayTimes:TArrayOfInteger;var SongNames:TArrayOfString;var MuMo:boolean):boolean;

var
 MAX_HEADER1:integer;
 UnpackedSize:integer;

 function FindStringTeg(teg:longword):string;
 var
  i,j:integer;
 begin
 Result := '';
 i := 0;
 while (i < MAX_HEADER1 - 4) and (i < UnpackedSize - 4) do
  begin
   if PLongWord(@SNDHBuffer[i])^ = teg then
    begin
     inc(i,4);
     j := i;
     while (i < UnpackedSize) and (SNDHBuffer[i] <> 0) do inc(i);
     dec(i,j);
     if i <> 0 then
      begin
       SetLength(Result,i);
       Move(SNDHBuffer[j],Result[1],i);
       Result := AtariCPToUtf8(Result);
      end;
     break;
    end;
   inc(i);
  end;
 end;

 function FindLTeg(teg:longword):integer;
 var
  i:integer;
 begin
 Result := -1;
 i := 0;
 while (i < MAX_HEADER1 - 4) and (i < UnpackedSize - 4) do
  begin
   if PLongWord(@SNDHBuffer[i])^ = teg then
    begin
     Result := i;
     break;
    end;
   inc(i);
  end;
 end;

 function FindWordTeg(teg:word):integer;
 var
  i,j:integer;
 begin
 Result := -1;
 i := 0;
 while (i < MAX_HEADER1 - 4) and (i < UnpackedSize - 4) do
  begin
   if PWord(@SNDHBuffer[i])^ = teg then
    begin
     j := SNDHBuffer[i + 2];
     if not (j in [$30..$39]) then exit;
     i := SNDHBuffer[i + 3];
     if not (i in [$30..$39]) then exit;
     i := i - $30 + (j - $30)*10;
     if i = 0 then exit;
     Result := i;
     break;
    end;
   inc(i);
  end;
 end;

 function FindWordTeg10(teg:word):integer;
 var
  i,j:integer;
  s:string;
 begin
 Result := -1;
 i := 0;
 while (i < MAX_HEADER1 - 2) and (i < UnpackedSize - 4) do
  begin
   if PWord(@SNDHBuffer[i])^ = teg then
    begin
     j := 2;
     s := '';
     while (j < 10) and (i + j < UnpackedSize) and (SNDHBuffer[i + j] <> 0) do
      begin
       s := s + char(SNDHBuffer[i + j]);
       inc(j);
      end;
     Val(s,i,j);
     if j <> 0 then exit;
     Result := i;
     break;
    end;
   inc(i);
  end;
 end;

 procedure AddDesc(const s:string);inline;
 begin
 if OtherShortDesc <> '' then
  OtherShortDesc := OtherShortDesc + ' ';
 OtherShortDesc := OtherShortDesc + s;
 end;

var
 i,o,j,t:integer;
 SNDHv2:boolean;
begin
UnpackedSize := Length(SNDHBuffer);
MAX_HEADER1 := UnpackedSize;
if FindLTeg(sndh_SNDH) < 0 then
 exit(False);
MAX_HEADER1 := FindLTeg(sndh_HDNS);
SNDHv2 := (MAX_HEADER1 <> -1) {and (MAX_HEADER1 and 1 = 0) too many SNDH-files with not even HDNS tag :(};
if not SNDHv2 then MAX_HEADER1 := MAX_HEADER;
if MAX_HEADER1 > UnpackedSize then MAX_HEADER1 := UnpackedSize;

{$IFDEF Dbg}
if SNDHv2 then DbgStr(#9'SNDH v2.x detected');
if (MAX_HEADER1 and 1 <> 0) then DbgStr(#9'HDNS at not even address');
{$ENDIF Dbg}

COMM := FindStringTeg(sndh_COMM);
TITL := FindStringTeg(sndh_TITL);
RIPP := FindStringTeg(sndh_RIPP);
CONV := FindStringTeg(sndh_CONV);
if SNDHv2 then
 YEAR := FindStringTeg(sndh_YEAR)
else
 YEAR := '';
NumberOfSongs := FindWordTeg(sndh_nn);
if NumberOfSongs <= 0 then
 NumberOfSongs := 1;
OtherShortDesc := '';
i := FindWordTeg(sndh_VBL);
if i > 0 then
 begin
  AddDesc('!V' + IntToStr(i));
  PlayFreq := i;
  PlayGen := GenVBL;
 end;
i := FindWordTeg10(sndh_TA);
if i > 0 then
 begin
  PlayFreq := i;
  PlayGen := GenTA;
  AddDesc('TA' + IntToStr(i));
 end
else
 begin
  i := FindWordTeg10(sndh_TB);
  if i > 0 then
   begin
    PlayFreq := i;
    PlayGen := GenTB;
    AddDesc('TB' + IntToStr(i));
   end
  else
   begin
    i := FindWordTeg10(sndh_TC);
    if i > 0 then
     begin
      PlayFreq := i;
      PlayGen := GenTC;
      AddDesc('TC' + IntToStr(i));
     end
    else
     begin
      i := FindWordTeg10(sndh_TD);
      if i > 0 then
       begin
        PlayFreq := i;
        PlayGen := GenTD;
        AddDesc('TD' + IntToStr(i));
       end;
     end;
   end;
 end;
SetLength(PlayTimes,NumberOfSongs);
SetLength(SongNames,NumberOfSongs);
for i := 0 to NumberOfSongs - 1 do
 begin
  PlayTimes[i] := PlayFreq * 300; //5 minutes
  SongNames[i] := '';
 end;

CurrentSong := 1;
if SNDHv2 then
 begin
  o := FindLTeg(sndh_TIME);
  if (o <> -1) and (o + NumberOfSongs * 2 <= MAX_HEADER1) then
   begin
    for i := 0 to NumberOfSongs - 1 do
     begin
      t := SNDHBuffer[o + 4 + i * 2] shl 8 + SNDHBuffer[o + 4 + i * 2 + 1];
      if t <> 0 then
       PlayTimes[i] := PlayFreq * t;
     end;
   end;
  o := FindLTeg(sndh__nSN); if o = -1 then o := FindLTeg(sndh_n_SN); //strange error in sndhv21.txt
  if o = -1 then
   begin
    o := FindLTeg(sndh__nST); //found in sndh45lf\BB\TEC_Demo.sndh
    {$IFDEF Dbg}
    if o <> -1 then DbgStr(#9'Undocumented !#ST tag found');
    {$ENDIF Dbg}
   end;
  if (o <> -1) and (o + NumberOfSongs * 2 <= MAX_HEADER1) then
   begin
    for i := 0 to NumberOfSongs - 1 do
     begin
      t := integer(SNDHBuffer[o + 4 + i * 2] shl 8 + SNDHBuffer[o + 4 + i * 2 + 1]) + o;
      j := t;
      while (j <= MAX_HEADER1) and (SNDHBuffer[j] <> 0) do inc(j);
      dec(j,t);
      if j <> 0 then
       begin
        SetLength(SongNames[i],j);
        Move(SNDHBuffer[t],SongNames[i][1],j);
        SongNames[i] := AtariCPToUtf8(SongNames[i]);
       end;
     end;
   end;
  o := FindWordTeg10(sndh__n); if o = -1 then o := FindWordTeg10(sndh_n_); //strange error in sndhv21.txt
  if (o > 0) and (o <= NumberOfSongs) then
   CurrentSong := o;
 end;

MuMo := FindLTeg(sndh_MuMo) <> -1;
if MuMo then
 begin
  {$IFDEF Dbg}
  DbgStr(#9'MuMo tag found');
  {$ENDIF Dbg}
  AddDesc('MuMo');
 end;
Result := True;
end;

end.

