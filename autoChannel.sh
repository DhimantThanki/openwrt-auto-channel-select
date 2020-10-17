#!/bin/ash
# 1->2.4ghz and 0->5ghz radio
# Basic Wi-Fi auto channel selector by Dhimant
# (c) 2020 Quantum Networks,India
# https://www.zengroup.co.in
#
# Dhimant Thanki 17/10/2020

# Config
TEST_INTERVAL=5
ITERATIONS=3

# No need to touch anything below, in most cases
if [[ -z $1 ]]; then
  echo "# Basic Wi-Fi auto channel selector by Dhimant"
  echo $0 [interface index]
  exit 1
fi

INTERFACE_INDEX=$1
SIGNAL=NO

scan() {
 /usr/sbin/iw wlan${INTERFACE_INDEX} scan | grep -E "primary channel|signal" | {
  while read line
  do
    FIRST=`echo "$line" | awk '{ print $1 }'`
    if [[ "$FIRST" == "signal:" ]]; then
      SIGNAL=`echo $line | awk '{ print ($2 < -65) ? "NO" : $2 }'`
    fi

    if [[ "$FIRST" == "*" -a "$SIGNAL" != "NO" ]]; then
      CHANNEL=`echo "$line" | awk '{ print $4 }'`
      eval "CURRENT_VALUE=CHANNEL_$CHANNEL"
      eval "CURRENT_VALUE=$CURRENT_VALUE"
      SUM=$(( $CURRENT_VALUE + 1 ))
      eval "CHANNEL_${CHANNEL}=$SUM"
    fi
  done

  echo $CHANNEL_1 $CHANNEL_6 $CHANNEL_11
 }
}

if [ $INTERFACE_INDEX -eq 1 ]
then
	for ITERATION in $(seq 1 1 $ITERATIONS)
	do
		[[ -n $DEBUG ]] && echo Iteration $ITERATION
		RESULT=$(scan)
		eval "RESULT_${ITERATION}_1=`echo $RESULT | awk '{ print $1 }'`"
		eval "RESULT_${ITERATION}_6=`echo $RESULT | awk '{ print $2 }'`"
		eval "RESULT_${ITERATION}_11=`echo $RESULT | awk '{ print $3 }'`"
		[[ $ITERATION -lt $ITERATIONS ]] && sleep $TEST_INTERVAL
	done

	for ITERATION in $(seq 1 1 $ITERATIONS)
	do
		for CHANNEL in 1 6 11
		do
			eval "CURRENT_VALUE=RESULT_${ITERATION}_${CHANNEL}"
			eval "CURRENT_VALUE=$CURRENT_VALUE"
			eval "CURRENT_AVG=AVG_$CHANNEL"
			eval "CURRENT_AVG=$CURRENT_AVG"
			eval "AVG_$CHANNEL=$(( ($CURRENT_AVG + $CURRENT_VALUE + 1) / 2 ))"

			[[ $ITERATION -eq $ITERATIONS -a -n $DEBUG ]] && echo Channel $CHANNEL has an average of $(( ($CURRENT_AVG + $CURRENT_VALUE + 1) / 2 )) networks
		done
	done

	if [ $AVG_1 -le $AVG_6 -a $AVG_1 -le $AVG_11 ]; then
		CHANNEL=1
	elif [ $AVG_6 -le $AVG_1 -a $AVG_6 -le $AVG_11 ]; then
		CHANNEL=6
	elif [ $AVG_11 -le $AVG_1 -a $AVG_11 -le $AVG_6 ]; then
		CHANNEL=11
	fi

	if [[ -n "$CHANNEL" ]]; then
		echo Setting channel to $CHANNEL
		if [ `echo $INTERFACE_INDEX | grep 0` ]
		then
			INTERFACE_INDEX=0
		else
			INTERFACE_INDEX=1
		fi

		ip link set wlan1 down
		iw dev wlan1 set channel $CHANNEL
		ip link set wlan1 up
	fi
fi

scan5() {
 /usr/sbin/iw wlan0 scan | grep -E "primary channel|signal" | {
  while read line
  do
    FIRST=`echo "$line" | awk '{ print $1 }'`
    if [[ "$FIRST" == "signal:" ]]; then
      SIGNAL=`echo $line | awk '{ print ($2 < -65) ? "NO" : $2 }'`
    fi

    if [[ "$FIRST" == "*" -a "$SIGNAL" != "NO" ]]; then
      CHANNEL=`echo "$line" | awk '{ print $4 }'`
      eval "CURRENT_VALUE=CHANNEL_$CHANNEL"
      eval "CURRENT_VALUE=$CURRENT_VALUE"
      SUM=$(( $CURRENT_VALUE + 1 ))
      eval "CHANNEL_${CHANNEL}=$SUM"
    fi
  done

  echo $CHANNEL_36 $CHANNEL_40 $CHANNEL_52 $CHANNEL_149
 }
}

#### main for 5ghz channel selection ####
SIGNAL=NO
if [ $INTERFACE_INDEX -eq 0 ]
then
	for ITERATION in $(seq 1 1 $ITERATIONS)
	do
		[[ -n $DEBUG ]] && echo Iteration $ITERATION
		RESULT=$(scan5)
		eval "RESULT_${ITERATION}_36=`echo $RESULT | awk '{ print $1 }'`"
		eval "RESULT_${ITERATION}_40=`echo $RESULT | awk '{ print $2 }'`"
		eval "RESULT_${ITERATION}_52=`echo $RESULT | awk '{ print $3 }'`"
		eval "RESULT_${ITERATION}_149=`echo $RESULT | awk '{ print $3 }'`"
		[[ $ITERATION -lt $ITERATIONS ]] && sleep $TEST_INTERVAL
	done

	for ITERATION in $(seq 1 1 $ITERATIONS)
	do
	for CHANNEL in 36 40 52 149
	do
		eval "CURRENT_VALUE=RESULT_${ITERATION}_${CHANNEL}"
		eval "CURRENT_VALUE=$CURRENT_VALUE"
		eval "CURRENT_AVG=AVG_$CHANNEL"
		eval "CURRENT_AVG=$CURRENT_AVG"
		eval "AVG_$CHANNEL=$(( ($CURRENT_AVG + $CURRENT_VALUE + 1) / 2 ))"

		[[ $ITERATION -eq $ITERATIONS -a -n $DEBUG ]] && echo Channel $CHANNEL has an average of $(( ($CURRENT_AVG + $CURRENT_VALUE + 1) / 2 )) networks
	done
	done

	if [ $AVG_36 -le $AVG_40 -a $AVG_36 -le $AVG_52 -a $AVG_36 -le $AVG_149 ]; then
	CHANNEL=36
	elif [ $AVG_40 -le $AVG_36 -a $AVG_40 -le $AVG_52 -a $AVG_40 -le $AVG_149 ]; then
	CHANNEL=40
	elif [ $AVG_149 -le $AVG_36 -a $AVG_149 -le $AVG_40 -a $AVG_149 -le $AVG_52 ]; then
	CHANNEL=149
	fi

	if [[ -n "$CHANNEL" ]]; then
		echo Setting channel to $CHANNEL
	if [ `echo $INTERFACE_INDEX | grep 0` ]
	then
		INTERFACE_INDEX=0
  	else
		INTERFACE_INDEX=1
  	fi

	ip link set wlan0 down
	iw dev wlan0 set channel $CHANNEL
	ip link set wlan0 up

	fi
fi
