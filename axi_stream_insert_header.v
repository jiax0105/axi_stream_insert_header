module axi_stream_insert_header #(
    parameter DATA_WD = 32,
    parameter DATA_BYTE_WD = DATA_WD / 8,
    parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD)
) (
    input                        clk,
    input                        rst_n,
    
    // AXI Stream input original data
    input                        valid_in,
    input [DATA_WD-1 : 0]        data_in,
    input [DATA_BYTE_WD-1 : 0]   keep_in,
    input                        last_in,
    output                       ready_in,
    
    // AXI Stream output with header inserted
    output                       valid_out,
    output [DATA_WD-1 : 0]       data_out,
    output [DATA_BYTE_WD-1 : 0]  keep_out,
    output                       last_out,
    input                        ready_out,
    
    // The header to be inserted to AXI Stream input
    input                        valid_insert,
    input [DATA_WD-1 : 0]        data_insert,
    input [DATA_BYTE_WD-1 : 0]   keep_insert,
    input [BYTE_CNT_WD-1 : 0]    byte_insert_cnt,
    output                       ready_insert
);


    reg ready_in_r1;
    reg ready_in_r2;

    reg valid_out_r;
    reg [DATA_WD-1 : 0]      data_out_r;
    reg [DATA_BYTE_WD-1 : 0] keep_out_r;
    reg last_out_r;

    reg ready_insert_r;

    assign ready_in  = ready_in_r1;
    assign valid_out = valid_out_r;
    assign data_out  = data_out_r;
    assign keep_out  = keep_out_r;
    assign last_out  = last_out_r;
    assign ready_insert = ready_insert_r;

    reg [DATA_WD-1 : 0] data_in_r;

    reg [DATA_BYTE_WD-1 : 0] keep_in_r;
    reg [DATA_BYTE_WD-1 : 0] keep_insert_r;

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            ready_insert_r <= 0;
        end 
        else if (ready_in) begin
            ready_insert_r <= 0;
        end
        else if (valid_insert && valid_in) begin
    	    ready_insert_r <= 1;
        end
        else begin
    	    ready_insert_r <= ready_insert_r;
        end
    end

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
    	    ready_in_r1 <= 0;
        end
        else if(last_in)begin
    	    ready_in_r1 <= 0;
        end
        else if(valid_in && valid_insert && ready_insert)begin
    	    ready_in_r1 <= 1;
        end
        else begin 
    	    ready_in_r1 <= ready_in_r1;
        end
    end

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
    	    ready_in_r2 <= 0;
        else
    	    ready_in_r2 <= ready_in_r1;
    end

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
    	    data_in_r <= 0;
        else
    	    data_in_r <= data_in;
    end
    
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
    	    keep_in_r <= 0;
        else
    	    keep_in_r <= keep_in;
    end

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            valid_out_r <= 0;
            data_out_r  <= 0;
            keep_out_r  <= 0;
            last_out_r  <= 0;
	        keep_insert_r <= 0;
        end
        else if(ready_out)begin
            if(ready_in_r1 && ready_in_r2)begin
                case(keep_insert)
   	                4'b1111: data_out_r <= data_in_r;
   	                4'b0111: data_out_r <= {data_in_r[23:0],data_in[DATA_WD-1:24]};
   	                4'b0011: data_out_r <= {data_in_r[15:0],data_in[DATA_WD-1:16]};
   	                4'b0001: data_out_r <= {data_in_r[7:0],data_in[DATA_WD-1:8]};
   	                4'b0000: data_out_r <= data_in;
   	                default: data_out_r <= data_out_r;
 	            endcase
 	            valid_out_r <= 1;
 	            keep_out_r  <= 4'b1111;
 	            last_out_r  <= 0;
	            keep_insert_r <= keep_insert;
            end
            else if(ready_in_r1)begin
                case(keep_insert)
   	                4'b1111: data_out_r <= data_insert;
   	                4'b0111: data_out_r <= {data_insert[23:0],data_in[DATA_WD-1:24]};
   	                4'b0011: data_out_r <= {data_insert[15:0],data_in[DATA_WD-1:16]};
   	                4'b0001: data_out_r <= {data_insert[7:0],data_in[DATA_WD-1:8]};
   	                4'b0000: data_out_r <= data_in;
   	                default: data_out_r <= data_out_r;
 	            endcase
 	            valid_out_r <= 1;
   	            keep_out_r  <= 4'b1111;
 	            last_out_r  <= 0;
	            keep_insert_r <= keep_insert_r;
            end
            else if(ready_in_r2)begin
	            case({keep_insert_r,keep_in_r})
	                8'b1111_1111:begin
				            data_out_r <= data_in_r;
				            keep_out_r <= 4'b1111;
			                end 
		            8'b0111_1111:begin
				            data_out_r <= {data_in_r[23:0],8'b0};
				            keep_out_r <= 4'b1110;
			                end
    		        8'b0011_1111:begin
				            data_out_r <= {data_in_r[15:0],16'b0};
				            keep_out_r <= 4'b1100;
		     	            end
		            8'b0001_1111: begin
				            data_out_r <= {data_in_r[7:0],24'b0};
				            keep_out_r <= 4'b1000;
			                end
		            8'b1111_1110:begin
				            data_out_r <= {data_in_r[23:0],8'b0};
				            keep_out_r <= 4'b1110;
			                end
		            8'b0111_1110:begin
				            data_out_r <= {data_in_r[23:8],16'b0};
				            keep_out_r <= 4'b1100;
			                end
    		        8'b0011_1110:begin
				            data_out_r <= {data_in_r[15:8],24'b0};
				            keep_out_r <= 4'b1000;
			                end
		            8'b1111_1100:begin
				            data_out_r <= {data_in_r[DATA_WD-1:16],16'b0};
				            keep_out_r <= 4'b1100;
			                end
		            8'b0111_1100:begin
				            data_out_r <= {data_in_r[23:16],24'b0};
				            keep_out_r <= 4'b1000;
			                end
		            8'b1111_1000:begin
				            data_out_r <= {data_in_r[DATA_WD-1:16],24'b0};
				            keep_out_r <= 4'b1000;
			                end
		            default : begin 
				            data_out_r <= data_in_r;
				            keep_out_r <= 4'b0;
			                end
	            endcase
	            valid_out_r <= 1;
    	        last_out_r  <= 1;
                keep_insert_r <= keep_insert_r;
            end
            else begin
                valid_out_r <= 0;
                data_out_r  <= data_out_r;
                keep_out_r  <= keep_out_r;
                last_out_r  <= 0;
                keep_insert_r <= keep_insert_r;
            end
        end	
        else begin
            valid_out_r <= 0;
	        data_out_r  <= data_out_r;
	        keep_out_r  <= keep_out_r;
	        last_out_r  <= 0;
        end
    end						
endmodule