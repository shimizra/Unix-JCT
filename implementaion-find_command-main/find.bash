#!/bin/bash
##############################
###Shimon MIzrahi 203375563###
##############################

argo=$@  #argo save all argument user pass.
type="non"; #type is the flag F=file D=dir.
name="false"; #name = true for know if user want to search by name.
size="false"; #size = true for know if user want to search by size.
countSize=0; #count save the $ possion that come ufter -size.
countExec=0;  #count save the $ possion that come ufter -exec.
countDepth=0; #count save the $ possion that come ufter -maxdepth.
countName=0; #count save the $ possion that come ufter -name.
reg="!NULL!"; #reg save the regex that user pass.
userSize=0; #the limit size of user want to search by.
userdepth=0 #the depth of user want to search by.
execVar="false" #execVar=false when user didnt use exe flag.
depthVar="false"; #depthVar=false when user didnt use depth flag.

if [ -z "$1" ]; then #if user didnt sent path.
   arguOne="./";
else
   arguOne=$1;
fi

flagSizeReg="false";
if [[ $argo == *"-size"* ]]; then #if user want to search by name.
     size="true" #if user looking by size.
         for i in $argo; do #we want to fine of -size possion.
         if [ ! $i == "-size" ]; then #when we find "-size"
            if [ $i == "-name" ]; then #when we find "-name"
                flagSizeReg="true";
                  let countSize=$countSize+2;
            else
             if [ $flagSizeReg == "true" ] && [ ${i:0:1} == "-" ]; then #becaue i f its regex so we jump obove it.
                   flagSizeReg="false";
             fi
            fi
          if [ $flagSizeReg == "false" ]; then
             let countSize=$countSize+1;
          fi
         else
             break; #if no found.
         fi
     done
     let countSize=$countSize+2; #to get the $ of size
     userSize=`echo ${@: countSize: 1}` #userSize=  the size of user want to search by.

     sizeFlage="false" #sizeFlage= "false" is mean that user sent size without falge for exmple size 100.

     opertor="equal"; #opertor = "equal" is defult chice, means that uaer wants equal of byte size.
     if [ ${userSize: 0: 1} == "-" ]; then #remove the "-" in userSize for get number.
          opertor="minus";#opertor = "minus" means that uaer wants less than size.
          userSize=${userSize: 1}
     fi

     if [ ${userSize: 0: 1} == "+" ]; then #remove the "+" in userSize for get number.
          opertor="plus";#opertor = "plus" means that uaer wants higher than size.
          userSize=${userSize: 1}
     fi

     if [ ${userSize: -1} == "c" ]; then #if userSize is bytes..
          sizeFlage="true"; #size flage sent
          userSize=${userSize: 0: -1} #userSize= remove c.
     fi

     if [ ${userSize: -1} == "b" ]; then #if userSize is block b..
          userSize=${userSize: 0: -1} #userSize= remove b.
          userSize=$((userSize * 512)) #mult in 512 its is size of block..
          sizeFlage="true"; #size flage sent
     fi

     if [ ${userSize: -1} == "w" ]; then #if userSize is 2 word..
          userSize=${userSize: 0: -1} #userSize= remove w.
          userSize=$((userSize * 2)) #mult in 2.
          sizeFlage="true"; #size flage sent
     fi

     if [ ${userSize: -1} == "k" ]; then #if userSize is kilo-byte..
          userSize=${userSize: 0: -1} #userSize= remove k.
          userSize=$((userSize * 1024)) #mult in kilo-byte = 1024.
          sizeFlage="true"; #size flage sent
     fi

     if [ ${userSize: -1} == "M" ]; then #if userSize is mega-byte..
          userSize=${userSize: 0: -1} #userSize= remove M.
          userSize=$((userSize * 1048576)) #mult in mega-byte = 1,048,576 (1024*1024).
          sizeFlage="true"; #size flage sent
     fi

     if [ ${userSize: -1} == "G" ]; then #if userSize is giga-byte..
          userSize=${userSize: 0: -1} #userSize= remove G.
          userSize=$((userSize * 1073741824)) #mult in giga-byte = 1,073,741,824 (1024*1024*1024).
          sizeFlage="true"; #size flage sent
     fi

     if [ $sizeFlage == "false" ]; then #if user didnt sent flag so the diffult is 512 byte block.
         userSize=$((userSize * 512)) #mult in 512 its is size of block..
     fi

fi


if [[ $argo == *"-name"* ]]; then #if user want to search by name.
     name="true"; #if user looking for name.
     for i in $argo; do #we want to fine of -name possion.
         if [ ! $i == "-name" ]; then #when we find "-name"
             let countName=$countName+1;
         else
             break; #if no found.
         fi
     done


     if [ $countName -gt 0 ]; then #if countName > 0 means that there are result.
          let countName=$countName+2; #to get the $ of regex.
          if [[ $argo == *"*"* ]] || [[ $argo == *"?"* ]]; then #if the is regex.
               tempReg=`echo ${@: countName}`; #tempReg save the temp result for valid.
               if [[ $tempReg =~ "*" ]] || [[ $tempReg =~ "?" ]]; then #if after use regex we found that no rusult.
                    reg="!NULL!";
               else #tempReg is fill result.
                    let countName=$countName-1; #to print the current countName.
                    reg=`echo [${@: countName: 2}]`; #reg save regex string and not the result because we want the strin regex for other dir in sub dir.
                    let countName=$countName+1;
               fi
          else #when no regex but is a simple string.
              reg=`echo ${@: countName: 1}` #reg save the simple string.
          fi
     fi
fi

flagNameReg="false"
if [[ $argo == *"-exec"* ]]; then #if user want to use exec flag.
    execVar="true"; #user use exec.
     for i in $argo; do #we want to fine of -exec possion.
         if [ ! $i == "-exec" ]; then #when we find "-exec"
            if [ $i == "-name" ]; then #when we find "-name"
                 flagNameReg="true";
                 let countExec=$countExec+2;
            else
            if [ $flagNameReg == "true" ] && [ ${i:0:1} == "-" ]; then #becaue i f its regex so we jump obove it.
                 flagNameReg="false";
            fi
           fi
            if [ $flagNameReg == "false" ]; then
                  let countExec=$countExec+1;
            fi
            # echo $countExec " " $i
         else
             break; #if no found.
        fi
     done
     let countExec=$countExec+2; #to get the $ of size
     userExec=`echo ${@: countExec}` #userExec=  exec command.
fi

if [[ $argo == *"-type d"* ]]; then #if argo containing d flag.
     type="D"; #type =D means that user looking for dir
elif [[ $argo == *"-type f"* ]]; then #if argo containing f flag.
     type="F"; #type =F means that user looking for file
fi

#
if [[ $argo == *"-maxdepth"* ]]; then #if user want to use -maxdepth flag.
    countDepth=0; #reset countDepth.
    depthVar="true"; #user use exec.
     for i in $argo; do #we want to fine of -maxdepth possion.
         if [ ! $i == "-maxdepth" ]; then #when we find "-maxdepth"
             let countDepth=$countDepth+1;
         else
             break; #if no found.
         fi
     done
     let countDepth=$countDepth+2; #to get the $ of -maxdepth
     userdepth=`echo ${@: countDepth: 1}` #userdepth= maxdepth command.
fi


if [[ $argo == *"-type d"* ]]; then #if argo containing d flag.
     type="D"; #type =D means that user looking for dir
elif [[ $argo == *"-type f"* ]]; then #if argo containing f flag.
     type="F"; #type =F means that user looking for file
fi


funcFind() #this function "funcFind" run (in recursive way) all over the dir for searching and printing user requirements.
{ #the function "funcFind" gers 3 arguments: $1 is the current user path (ofter that is will change in recursive parram for gerring depth, $2 save current depth.
   local path=$1 #current path.
   local depth=$2; #depth save the depth when we run on tree.
   #


   if [ $depthVar == "true" ]; then # if user wants to use maxdepth flag.

       if [ $depth -ge $userdepth ]; then #if we get more depth then user command.
            return;
       fi
  fi

   if [ $name == "true" ]; then #if user looking for name.
      cd $path #we get into path for get current info.
      if [ ${reg: -1} == "]" ]; then #if reg is reg [string].
           local currentReg=`echo ${reg:1:-1}` #getting the result of current dir by regex.
      else #is simple string.
           local currentReg=$reg #we will search by string (not regex).
      fi
      #let depth=$depth+1;
      cd ~ #after we get into path, we return to main path for next round.
   fi

   for element in `ls $path`; do #runing al over the result of user command.

        if [ ${path: -1} == "/" ]; then #if its the first round.
             local fullPath=$path$element; #not need to add "/" between $path and $element.
        else #its not the first round.
             local fullPath=$path/$element #need to add "/" between $path and $element.
         fi


        if [ -d $fullPath ]; then #if element is dir only

            let local RecDepth=$depth+1; #is a dir so we get one more depth.

            if [ $type == "D" ] || [ $type == "non" ]; then #if user want dir.
                  #if [ $count -gt 0 ]; then #

                if [ $name == "true" ]; then #if user looking for name.
                   for j in $currentReg; do #we runing on result.
                      if [ $j == $element ]; then #if $j == $element means we found the result.
                        if [ ! $size == "true" ]; then #user not sort size.
                         if [ $execVar == "true" ]; then #if user add exec command.
                           echo `$userExec $fullPath`
                         else
                           echo $fullPath
                         fi
                        fi
                      fi
                  done
                fi

                if [ $name == "false" ] && [ $size == "false" ]; then #user not sort by name or size.
                   if [ $execVar == "true" ]; then #if user add exec command.
                     echo `$userExec $fullPath`
                   else
                     echo $fullPath
                   fi
                fi

                     #fi
            fi

           funcFind $fullPath $RecDepth #recursive function "funcFind" call to get all dir.

            else #means we getting to files.
               if [ $type == "F" ] || [ $type == "non" ]; then #if user wants files.
                     #if [ $count -gt 0 ]; then #

                 if [ $name == "true" ] && [ $size == "true" ] && [ -f $fullPath ]; then #if user looking for name and size.


                   for r in $currentReg; do #we runing on result.
                       if [ $r == $element ]; then #if $j == $element means we found the result.


                         local sizeTemp=`wc -c $fullPath`; # sizeTemp= size bytes of each element and name of path..
                         local bytes=`echo $sizeTemp | awk '{print $1;}'` #bytes= total bytes of each element.

                          if [ $opertor == "minus" ]; then #if user want the lowwer filse byte.
                             if [ $userSize -gt $bytes ]; then #if user size > our files.
                               if [ $execVar == "true" ]; then #if user add exec command.
                                  echo `$userExec $fullPath`
                               else
                                  echo $fullPath
                               fi
                             fi
                         fi

                        if [ $opertor == "plus" ]; then
                           if [ $userSize -lt $bytes ]; then #if user size < our files.
                             if [ $execVar == "true" ]; then #if user add exec command.
                                 echo `$userExec $fullPath`
                                   else
                                     echo $fullPath
                                 fi
                             fi
                        fi

                          if [ $opertor == "equal" ]; then
                               if [ $bytes -eq $userSize ]; then #if user size == our files.
                                  if [ $execVar == "true" ]; then #if user add exec command.
                                    echo `$userExec $fullPath`
                                  else
                                    echo $fullPath
                                   fi
                               fi
                         fi

                       fi
                       done


                else

                  if [ $name == "true" ]; then #if user looking for name.
                      for r in $currentReg; do #we runing on result.
                       if [ $r == $element ]; then #if $j == $element means we found the result.
                         if [ $execVar == "true" ]; then #if user add exec command.
                            echo `$userExec $fullPath`
                             #echo "888888888888"
                         else
                             echo $fullPath
                         fi
                       fi
                       done
                  fi

                      if [ $size == "true" ] && [ -f $fullPath ]; then #if user looking for size and path is file.
                         local sizeTemp=`wc -c $fullPath`; # sizeTemp= size bytes of each element and name of path..
                         local bytes=`echo $sizeTemp | awk '{print $1;}'` #bytes= total bytes of each element.

                          if [ $opertor == "minus" ]; then #if user want the lowwer filse byte.
                             if [ $userSize -gt $bytes ]; then #if user size > our files.
                               if [ $execVar == "true" ]; then #if user add exec command.
                                  echo `$userExec $fullPath`
                               else
                                  echo $fullPath
                               fi
                             fi
                         fi

                        if [ $opertor == "plus" ]; then
                           if [ $userSize -lt $bytes ]; then #if user size < our files.
                             if [ $execVar == "true" ]; then #if user add exec command.
                                 echo `$userExec $fullPath`
                                   else
                                     echo $fullPath
                                 fi
                             fi
                        fi

                          if [ $opertor == "equal" ]; then
                               if [ $bytes -eq $userSize ]; then #if user size == our files.
                                  if [ $execVar == "true" ]; then #if user add exec command.
                                    echo `$userExec $fullPath`
                                  else
                                    echo $fullPath
                                   fi
                               fi
                         fi

                  fi
             fi
               #print
                       if [ $name == "false" ] && [ $size == "false" ]; then #user not sort by name or size
                         if [ $execVar == "true" ]; then #if user add exec command.
                          echo `$userExec $fullPath`
                         else
                          echo $fullPath
                       fi

                      fi
                     #fi
           fi
      fi
   done
}


sumDepth=0; #reser depth.
funcFind $arguOne $sumDepth #implementaion function "funcFind".