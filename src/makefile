# Compiler and Simulation Tools
GHDL = ghdl
WAVE = gtkwave

# Directories
SRC_DIR = hdl
BIN_DIR = bin
TB_DIR = tb

# Project Files
SRC = $(wildcard $(SRC_DIR)/*.vhd)
TB = $(TB_DIR)/tb_Top.vhd
OUT = $(BIN_DIR)/sim
WAVE_FILE = $(BIN_DIR)/waveform.vcd

# GHDL Flags
GHDLFLAGS = --workdir=$(BIN_DIR) --ieee=synopsys -fexplicit

# Create bin directory if it doesn't exist
$(BIN_DIR):
	mkdir -p $(BIN_DIR)

# Compile VHDL files
compile: $(BIN_DIR)
	$(GHDL) -a $(GHDLFLAGS) $(SRC) $(TB)
	$(GHDL) -e $(GHDLFLAGS) -o $(OUT) tb_Top

# Run simulation
run: compile
	$(GHDL) -r tb_Top --vcd=$(WAVE_FILE)

# Open waveform in GTKWave
wave:
	$(WAVE) $(WAVE_FILE) &

# Clean up generated files
clean:
	rm -rf $(BIN_DIR)/*