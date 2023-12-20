function logArguments(x){
    console.log("x = "+x);
    for(i=0; i<arguments.length; i++)
    console.log("argument"+(i+1)+" = "+arguments[i])
   }

   logArguments(1, 5, 19, 'abc')