#Requires AutoHotkey v1.1.33+
Hash(Options, ByRef Var, nBytes:="") { ;                                 Hash() v0.37 by SKAN on D444/D445 @ tiny.cc/hashit
	Local
	  HA := {"ALG":"SHA256","BAS":0, "UPP":1, "ENC":"UTF-8"}
	  Loop, Parse, % Format("{:U}", Options), %A_Space%, +
		 A := StrSplit(A_LoopField, ":", "+"), HA[ SubStr(A[1], 1, 3) ] := A[2]
	
	  HA.X := ( HA.ENC="UTF-16" ? 2 : 1)
	  OK1  := { "SHA1":1, "SHA256":1, "SHA384":1, "SHA512":1, "MD2":1, "MD4":1, "MD5":1 }[ HA.ALG ]
	  OK2  := { "CP0":1, "UTF-8":1, "UTF-16":1}[ HA.ENC ]
	  NaN  := ( StrLen(nBytes) And (nBytes != Round(nBytes)) ),                    lVar := StrLen(Var)
	  pNum := ( lVar And [var].GetCapacity(1)="" And (Var = Abs(Round(Var))) ),    nVar := VarSetCapacity(Var)
	
	  If ( OK1="" Or OK2="" Or NaN=1 Or lVar<1 Or (pNum=1 And nBytes<1) Or (pNum=0 And nVar<nBytes))
		 Return ( 0, ErrorLevel := OK1="" ? "Algorithm not known.`n=> MD2 MD4 MD5 SHA1 SHA256 SHA384 SHA512`nDefault: SHA256"
								:  OK2="" ? "Codepage incorrect.`n=> CP0 UTF-16 UTF-8`nDefault: UTF-8"
								:  NaN=1  ? "nBytes in incorrect format"
								:  lVar<1 ? "Var is empty. Nothing to hash."
				  : (pNum=1 And nBytes<1) ? "Pointer requires nBytes greater than 0."
			   : (pNum=0 And nVar<nBytes) ? "Var's capacity is lesser than nBytes." : "" )
	
	  hBcrypt := DllCall("Kernel32.dll\LoadLibrary", "Str","Bcrypt.dll", "Ptr")
	  DllCall("Bcrypt.dll\BCryptOpenAlgorithmProvider", "PtrP",hAlg:=0, "WStr",HA.ALG, "Ptr",0, "Int",0, "UInt")
	  DllCall("Bcrypt.dll\BCryptCreateHash", "Ptr",hAlg, "PtrP",hHash:=0, "Ptr", 0, "Int", 0, "Ptr",0, "Int",0, "Int", 0)
	
	  nLen := 0, FileLen := File := rBytes := sStr := nErr := ""
	  If ( nBytes!="" And (pBuf:=pNum ? Var+0 : &Var) )
			 {
			   If ( nBytes<=0  )
					nBytes := StrPut(Var, HA.ENC)
				  , VarSetCapacity(sStr, nBytes * HA.X)
				  , nBytes := ( StrPut(Var, pBuf := &sStr, nBytes, HA.ENC) - 1 ) * HA.X
			   nErr := DllCall("Bcrypt.dll\BCryptHashData", "Ptr",hHash, "Ptr",pBuf, "Int",nBytes, "Int", 0, "UInt")
	  } Else {
			   File := FileOpen(Var, "r -rwd")
			   If  ( (FileLen := File.Length) And VarSetCapacity(Bin, 65536) )
					 Loop
					 If ( rBytes := File.RawRead(&Bin, 65536) )
						nErr   := DllCall("Bcrypt.dll\BCryptHashData", "Ptr",hHash, "Ptr",&Bin, "Int",rBytes, "Int", 0, "Uint")
					 Until ( nErr Or File.AtEOF Or !rBytes )
			   File := ( FileLen="" ? 0 : File.Close() )
			 }
	
	  DllCall("Bcrypt.dll\BCryptGetProperty", "Ptr",hAlg, "WStr", "HashDigestLength", "UIntP",nLen, "Int",4, "PtrP",0, "Int",0)
	  VarSetCapacity(Hash, nLen)
	  DllCall("Bcrypt.dll\BCryptFinishHash", "Ptr",hHash, "Ptr",&Hash, "Int",nLen, "Int", 0)
	  DllCall("Bcrypt.dll\BCryptDestroyHash", "Ptr",hHash)
	  DllCall("Bcrypt.dll\BCryptCloseAlgorithmProvider", "Ptr",hAlg, "Int",0)
	  DllCall("Kernel32.dll\FreeLibrary", "Ptr",hBCrypt)
	
	  If ( nErr=0 )
		 VarSetCapacity(sStr, 260, 0),  nFlags := HA.BAS ? 0x40000001 : 0x4000000C
	   , DllCall("Crypt32\CryptBinaryToString", "Ptr",&Hash, "Int",nLen, "Int",nFlags, "Str",sStr, "UIntP",130)
	   , sStr := ( nFlags=0x4000000C And HA.UPP ? Format("{:U}", sStr) : sStr )
	
	Return ( sStr, ErrorLevel := File=0    ? ( FileExist(Var) ? "Open file error. File in use." : "File does not exist." )
							   : FileLen=0 ? "Zero byte file. Nothing to hash."
					: (FileLen & rBytes=0) ? "Read file error."
									: nErr ? Format("Bcrypt error. 0x{:08X}", nErr)
								 : nErr="" ? "Unknown error." : "" )
	}

MsgBox % Hash("", "SKAN", -1)