# RSAHelper
Powershell cmdlets to work with RSA keys through Big integer numbers.

### PrimesToRSAParameters
Generates Public+Private key pair based on two big primes
```
$p1 = [System.Numerics.BigInteger]::Parse("5477603193485151533926724478941715158170778131000592828807")
$p2 = [System.Numerics.BigInteger]::Parse("5074615703421775174386027994334630811821327450578668312199")

$rsa = New-Object System.Security.Cryptography.RSACryptoServiceProvider
$RSAParameters = PrimesToRSAParameters $p1 $p2

$rsa.ImportParameters($RSAParameters)
```
### RSAParametersToBigInteger
Reads RSAParameters structure and output it as hashtable with BigIntegers for further RSA exploration.
```
$rsa = New-Object System.Security.Cryptography.RSACryptoServiceProvider(1024)
$RSAParameters = $rsa.ExportParameters($true)
RSAParametersToBigInteger $RSAParameters
```
