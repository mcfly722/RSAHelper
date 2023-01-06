function PrimesToRSAParameters{
    <#
        .SYNOPSIS
        Build RSA Private + Public keys based on two big primes

        .DESCRIPTION

        .PARAMETER prime1
        First Prime

        .PARAMETER prime2
        Second Prime

        .PARAMETER exponent
        Exponent (default=65537)

        .EXAMPLE
        $p1 = [System.Numerics.BigInteger]::Parse("5477603193485151533926724478941715158170778131000592828807")
        $p2 = [System.Numerics.BigInteger]::Parse("5074615703421775174386027994334630811821327450578668312199")

        $rsa = New-Object System.Security.Cryptography.RSACryptoServiceProvider
        $RSAParameters = PrimesToRSAParameters $p1 $p2

        $rsa.ImportParameters($RSAParameters)
    #>

    param(
        [System.Numerics.BigInteger][Parameter(Mandatory = $true)]$prime1,
        [System.Numerics.BigInteger][Parameter(Mandatory = $true)]$prime2,
        [System.Numerics.BigInteger][Parameter(Mandatory = $false)]$exponent = [System.Numerics.BigInteger]::Parse("65537")
    )

    function inverse_mod([System.Numerics.BigInteger] $a,[System.Numerics.BigInteger] $p){
        # res = a^{-1} (mod p)
        $val = [System.Numerics.BigInteger]0
        $nt = [System.Numerics.BigInteger]1
        $r = $p
        $nr = $a
        while ($nr -ne [BigInt]0) {
            $q = [BigInt]::Divide($r,$nr)
            $val_temp = $nt
            $nt = [BigInt]::Subtract($val,[BigInt]::Multiply($q,$nt))
            $val = $val_temp
            $val_temp = $nr
            $nr = [BigInt]::Subtract($r, [BigInt]::Multiply($q,$nr))
            $r = $val_temp
        }
        if ($r -gt 1) {return -1}
        if ($val -lt 0) {$val = [BigInt]::Add($val,$p)}
        return $val
    }

    $d = inverse_mod $exponent (($prime1-1)*($prime2-1))

    return New-Object System.Security.Cryptography.RSAParameters -Property @{
        P        = $prime1.ToByteArray(1,-1)
        Q        = $prime2.ToByteArray(1,-1)
        Modulus  = ($prime1 * $prime2).ToByteArray(1,-1)
        InverseQ = ([System.Numerics.BigInteger]::ModPow($prime2, $prime1 - 2, $prime1)).ToByteArray(1,-1)
        Exponent = ($exponent).ToByteArray(1,-1)
        D        = $d.ToByteArray(1,-1)
        DP       = ($d % ($prime1 - 1)).ToByteArray(1,-1)
        DQ       = ($d % ($prime2 - 1)).ToByteArray(1,-1)
    }
}

function RSAParametersToBigInteger{
    <#
        .SYNOPSIS
        Converts RSAParameters to Big Ingteger numbers

        .DESCRIPTION

        .PARAMETER RSAParameters
        RSAParameters

        .EXAMPLE
        $rsa = New-Object System.Security.Cryptography.RSACryptoServiceProvider(1024)
        $RSAParameters = $rsa.ExportParameters($true)
        RSAParametersToBigInteger $RSAParameters
    #>
    param([Parameter(Mandatory = $true)][System.Security.Cryptography.RSAParameters]$RSAParameters)

    return @{
        'Modulus'  = [System.Numerics.BigInteger]::Parse("0"+[System.Convert]::ToHexString($RSAParameters.Modulus) ,'AllowHexSpecifier')
        'Exponent' = [System.Numerics.BigInteger]::Parse("0"+[System.Convert]::ToHexString($RSAParameters.Exponent),'AllowHexSpecifier')
        'P'        = [System.Numerics.BigInteger]::Parse("0"+[System.Convert]::ToHexString($RSAParameters.P)       ,'AllowHexSpecifier')
        'Q'        = [System.Numerics.BigInteger]::Parse("0"+[System.Convert]::ToHexString($RSAParameters.Q)       ,'AllowHexSpecifier')
        'DP'       = [System.Numerics.BigInteger]::Parse("0"+[System.Convert]::ToHexString($RSAParameters.DP)      ,'AllowHexSpecifier')
        'DQ'       = [System.Numerics.BigInteger]::Parse("0"+[System.Convert]::ToHexString($RSAParameters.DQ)      ,'AllowHexSpecifier')
        'InverseQ' = [System.Numerics.BigInteger]::Parse("0"+[System.Convert]::ToHexString($RSAParameters.InverseQ),'AllowHexSpecifier')
        'D'        = [System.Numerics.BigInteger]::Parse("0"+[System.Convert]::ToHexString($RSAParameters.D)       ,'AllowHexSpecifier')
    }
}
