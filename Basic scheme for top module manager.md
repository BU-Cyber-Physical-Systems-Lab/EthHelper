
assume lower-level modules act all the same (i.e. all the same controls and interface)
	-inputs: Singular Channel, TopModule_ready, Reset, Clock
	-outputs: Data, subModule_Valid, subModule_in_progress


```
// top_module.sv

// how many channels this module supports
localparam channels = 5
//the bit needed to represent this channels in binary
localparam channels_bits = $clog(channels)

//send reset to individual submodules (and keep unwanted submodules in reset)
reg resets[channels-1:0];

// how the top module signals a specific sumodule that the transaction can proceed
wire [channels-1:0] ready;

// how the submodules will signa to the top module that they have valid data (after having detected a handshake between the two orginal axi interfaces), or a multi-clock cycle transaction is still in progress (e.g. R/w).
wire [channels-1:0],valid,in_progress;


// the logic with which we pick a submodule in round robin for transmission
assign ready = (stream_tready && (valid[last_index] || in_progress[last_index]))? encodings[last_index] :
(stream_tready && (valid[last_index+1] || in_progress[last_index+1]))? encodings[last-index+1] : //continue for all bit in channels then last else is NONE_HOT;

// with the same logicas the ready, we send the matching data
assign tdata = (ready[last_index])?  :
(ready[last_index+1] || in_progress[last_index+1])? submodule-data[last_index] : //continue for all bit in channels then last else is NONE_HOT;

// to implement round robin we need a register that will cycle between all the possible channels (when they are valid)
enum reg [channels_bits-1:0] {AR=0,AW=1,R=2,W=3,B=4} last_index;

// mnemonics for remembering how we identify each channel in the one-hot encoding used by the ready wire
enum {NONE_HOT= 5b'00000, AR_HOT=5'b00001,AW_HOT=5'b00010}

// since everything is relative to last_index we need also the one-hot encodings for the ready to be realtive to last_index
reg [channels-1:0][channels-1:0] encodings;

//finally also the data that we send to the AXI4stream has to be relative to last_index
wire [channels-1:0][channels-1:0] submodule_data;

//example submodules
AXIToStream_Ax#(//params) AR (
//AXI interfaces
.output_data(submodule_data[0]),
.ready(ready[0]),
.valid(valid[0]),
.in_progress(in_progress[0]),
.resetn(resetsn[0]),
.clk(clk)
);

AXIToStream_Ax#(//params) AW (
//AXI interfaces
.output_data(submodule_data[1]),
.ready(ready[1]),
.valid(valid[1]),
.in_progress(in_progress[1]),
.resetn(resetsn[1]),
.clk(clk)
);

integer i;
//for loop may be constrained to a genvar block
always @(posedge clk){

	//this can be a separate always block, and it only initializes the encoding register.
	encodings[0] <= AR_HOT;
	encodings[1] <= AW_HOT;
	...
	encodings[5]<= NONE;
	....
	//continue for all the bits in channels

	// Here we need to check all channels starting from last_index and accept the first valid channel (meaning that this for should unroll in a cascadin if-else for all the entries encoded by the channels bit.)
	// @todo if this does not work unroll manually
	for(i=0;i<2^channels_bits;i++) 
		if(valid[last_index+i] || in_progress[last_index+i]){
			//@todo check if increment of lastindex wraps properly (unsued entries are never valid or inprogress)
			//@todo maybe we can do seomthing more efficient than incrementing last index.
			last_index <= i+(in_progress[last-index+i])? last_index : last-index  +1; 
			break;
		}
```
more legible version of the for loop
```
	always @(posedge clk){
		if(valid[last_index] || in_progress[last_index]){
			last_index <= (in_progress[last-index])? last_index : last-index  +1; 
		} else if (valid[last_index+1] || in_progress[last_index+1]){
			last_index <= (in_progress[last-index+1])? last_index : last-index+1  +1; 
	}
```



For Submodules
	-Expected Behaviour: when in reset allow all handshakes from AxiM to AXIS to go through 
