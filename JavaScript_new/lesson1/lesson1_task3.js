const sBIRTHDAY = '05.02.2020'

function DefineAge(sBirthdayDate)
{
	// Default age
	let nAge = -1

	// Get current date
	let objCurrentDate = new Date()	
	let nCurrentYear   = objCurrentDate.getFullYear()
	let nCurrentMonth  = objCurrentDate.getMonth()
	let nCurrentDay    = objCurrentDate.getDate()

	//Parse input parameter - [day, month, year]
	let listBirthday = sBirthdayDate.split('.')

	// Define difference of years
	if (nCurrentYear >= listBirthday[2])
		nAge = nCurrentYear - listBirthday[2]

	// Correct age
	if ((nCurrentMonth <= listBirthday[1]) && (nCurrentDay < listBirthday[0]))
		nAge -= 1

	if (nAge < 0)
		alert('Incorrect birthday date was entered')
		
	return nAge
}

let nAge = DefineAge(sBIRTHDAY)
if (nAge >= 0)
	alert('Your age is ' + nAge + ' years old')
