backup_dir=$(shell head -n 1 all_in_one.net | cut -d '"' -f 2)
snapshot = "snapshot_iter_25000.solverstate"
weights = "$(SCRATCH_DIR)/deeptransient/caffemodels/transientneth.caffemodel"
log_file = output.log
gpu_node = 0

train: parse sync
	time $(CAFFE_DIR)/build/tools/caffe.bin train -weights $(weights) -gpu $(gpu_node) --solver=solver.prototxt 2>&1 | tee $(log_file)

retrain: parse sync
	time $(CAFFE_DIR)/build/tools/caffe.bin train -gpu $(gpu_node) --solver=solver.prototxt 2>&1 | tee $(log_file)

train_cpu: parse sync
	time $(CAFFE_DIR)/build/tools/caffe.bin train --solver=solver.prototxt 2>&1 | tee $(log_file)

parse:
	python parser.py

deploy: parse sync
	python deploy_net.py

debug: parse sync
	python -m pdb deploy_net.py

clean_snapshots:
	python remove_old_snapshots.py

sync:
	sync

backup:
	mkdir -p $(backup_dir) 2> /dev/null
	cp all_in_one.net deploy_net.py $(backup_dir) -f
	cp $(log_file) $(backup_dir) -i

resume: parse sync
	$(CAFFE_DIR)/build/tools/caffe.bin train --solver=solver.prototxt --snapshot=$(snapshot) 2>&1 | tee -a $(log_file)

draw: parse sync
	python $(CAFFE_DIR)/python/draw_net.py train_test.prototxt ~/net.png

clean:
	rm deploy.prototxt train_test.prototxt solver.prototxt -f
