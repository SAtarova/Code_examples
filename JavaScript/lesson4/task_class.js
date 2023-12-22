function details()
    {
    alert(`Brand: ${car.proizv}\n`)
    }

var car =  
{
    proizv = "BMV",
    model = "123",
    year_of_create = "2022",
    avg_speed = 200
}

details()

var drob1 = {
    chislit = 10,
    znamenat = 20}

var drob2 = {chislit = 3, znamenat = 15}

function SumDrob(d1, d2)
    {
        let dr = {chislit = 10; znamenat = 20
    }
        if (d1.znamenat == d2.znamenat)
        {
            dr.znamenat = d1.znamenat
            dr.chislit = d1.chislit + d2.chislit
            return dr        
        }
        else
        {
            dr.znamenat = d1.znamenat * d2.znamenat
            dr.chislit = d1.chislit * d2.znamenat - d1.znamenat * d2.chislit
            return dr 
        }
    }


