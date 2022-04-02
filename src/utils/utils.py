from multiprocessing import cpu_count

def get_num_workers():
    if cpu_count() > 5:
        num_workers = cpu_count() // 2
    elif cpu_count() < 2:
        num_workers = 0
    else:
        num_workers = 2
        
    return num_workers
