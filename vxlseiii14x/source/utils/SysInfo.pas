unit SysInfo;

// CPU detection code adapted from http://www.bvbcode.com/code/06qjxeis-1648646

interface

const
   CPU_TYPE_INTEL     = 1;
   CPU_TYPE_AMD       = 2;
   VendorIDIntel: array [0..11] of Char = 'GenuineIntel';
   VendorIDAMD: array [0..11] of Char = 'AuthenticAMD';

type
   TSysInfo = class
      private
         procedure CallCPUID(ValueEAX, ValueECX: Cardinal; var ReturnedEAX, ReturnedEBX, ReturnedECX, ReturnedEDX);
         procedure ProcessIntel(HiVal: Cardinal);
         procedure ProcessAMD(HiVal: Cardinal);
         procedure DetectCPU;
      public
         CPUType: Byte;
         VendorIDString: array [0..11] of Char;
         CpuName: array [0..47] of Char;
         PhysicalCore: Byte;

         // Constructors and Destructors.
         constructor Create;
   end;

implementation

procedure TSysInfo.CallCPUID(ValueEAX, ValueECX: Cardinal; var ReturnedEAX, ReturnedEBX, ReturnedECX, ReturnedEDX);
begin
  asm
    PUSH    EDI
    PUSH    EBX

    MOV     EAX, ValueEAX
    MOV     ECX, ValueECX
//    CPUID
    DB      0FH
    DB      0A2H
    MOV     EDI, ReturnedEAX
    MOV     Cardinal PTR [EDI], EAX
    MOV     EAX, ReturnedEBX
    MOV     EDI, ReturnedECX
    MOV     Cardinal PTR [EAX], EBX
    MOV     Cardinal PTR [EDI], ECX
    MOV     EAX, ReturnedEDX
    MOV     Cardinal PTR [EAX], EDX
    POP  EBX
    POP  EDI
  end;
end;

procedure TSysInfo.ProcessIntel(HiVal: Cardinal);
var
   ExHiVal, EAX, EBX, ECX, EDX: Cardinal;
begin
   CpuType := CPU_TYPE_INTEL;
   if HiVal >= 4 then
   begin
      CallCPUID(4, 0, EAX, EBX, ECX, EDX);
      PhysicalCore := ((EAX and $FC000000) shr 26) + 1;
   end;
   CallCPUID($80000000, 0, ExHiVal, EBX, ECX, EDX);
   if ExHiVal >= $80000002 then
      CallCPUID($80000002, 0, CpuName[0], CpuName[4], CpuName[8], CpuName[12]);
   if ExHiVal >= $80000003 then
      CallCPUID($80000003, 0, CpuName[16], CpuName[20], CpuName[24], CpuName[28]);
   if ExHiVal >= $80000004 then
      CallCPUID($80000004, 0, CpuName[32], CpuName[36], CpuName[40], CpuName[44]);
end;


procedure TSysInfo.ProcessAMD(HiVal: Cardinal);
var
   ExHiVal, EAX, EBX, ECX, EDX: Cardinal;
begin
   CpuType := CPU_TYPE_AMD;
   CallCPUID($80000000, 0, ExHiVal, EBX, ECX, EDX);
   if ExHiVal >= $80000002 then
      CallCPUID($80000002, 0, CpuName[0], CpuName[4], CpuName[8], CpuName[12]);
   if ExHiVal >= $80000003 then
      CallCPUID($80000003, 0, CpuName[16], CpuName[20], CpuName[24], CpuName[28]);
   if ExHiVal >= $80000004 then
      CallCPUID($80000004, 0, CpuName[32], CpuName[36], CpuName[40], CpuName[44]);
   if ExHival >= $80000008 then    //get PhysicalCore;
   begin
      CallCPUID($80000008,0, EAX, EBX, ECX, EDX);
      PhysicalCore := ECX and $F + 1;
   end;
end;

procedure TSysInfo.DetectCPU;
var
   Hival: Cardinal;
begin
   PhysicalCore := 1;
   CallCPUID(0, 0, HiVal, VendorIDString[0], VendorIDString[8], VendorIDString[4]);
   if VendorIDString = VendorIDIntel then
      ProcessIntel(HiVal)
   else if VendorIDString = VendorIDAMD then
      ProcessAMD(HiVal);
end;

constructor TSysInfo.Create;
begin
   DetectCPU;
end;

end.

