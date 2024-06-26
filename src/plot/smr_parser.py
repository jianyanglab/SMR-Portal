from pathlib import Path

import pandas as pd
from tqdm import tqdm
import sys

def parse_esi_file(esi_file):
    '''
    14	rs376547468	0	19000236	C	A	0.0168539
    14	rs796628752	0	19000384	G	A	0.0361111
    '''
    esi_df = pd.read_csv(esi_file, sep='\t', header=None)
    esi_df.columns = ['chr', 'snp', 'gp', 'bp', 'a1', 'a2', 'maf']
    return esi_df


def parse_epi_file(epi_file):
    '''
1    probe1001   0   924243  Gene01  +
1    probe1002   0   939564  Gene02  -
1    probe1003   0   1130681 Gene03  -
    '''
    epi_df = pd.read_csv(epi_file, sep='\t', header=None)
    epi_df.columns = ['chr', 'probe', 'gp', 'bp', 'gene', 'strand']
    return epi_df


# %%
import struct


def read_int32(file):
    return struct.unpack('<i', file.read(4))[0]


def read_uint64(file):
    return struct.unpack('<Q', file.read(8))[0]

def read_uint64s(file, count):
    return struct.unpack(f'<{count}Q', file.read(8 * count))

def read_floats(file, count):
    return struct.unpack(f'<{count}f', file.read(4 * count))


def read_uint32s(file, count):
    return struct.unpack(f'<{count}I', file.read(4 * count))


# %%
def parse_besd(file_path,
               file_format=None
               ):
    with open(file_path, 'rb') as file:
        # open(epi_file_path, 'r') as epi_file, \
        # open(esi_file_path, 'r') as esi_file:

        # Read basic info
        file_format_tmp = read_int32(file)
        file_format = file_format if file_format is not None else file_format_tmp
        _ = read_int32(file)  # sample number
        esi_num = read_int32(file)
        epi_num = read_int32(file)
        _ = [read_int32(file) for _ in range(12)]  # reserved

        # Check if esi_num and epi_num match the line counts of respective files
        # assert esi_num == sum(1 for _ in esi_file)
        # assert epi_num == sum(1 for _ in epi_file)

        if file_format == 5:  # Dense format
            print("Reading dense format...")
            raise ValueError("Dense format not supported for single gene parsing")
            prob_dict = {}

            for i in range(epi_num):
                beta_values = read_floats(file, esi_num)
                se_values = read_floats(file, esi_num)
                prob_dict[i] = pd.DataFrame({'beta': beta_values, 'se': se_values})
            return prob_dict

        elif file_format == 3:  # Sparse format
            print("Reading sparse format...")
            # Initialize value_num_count and offsets
            value_num_count = read_uint64(file)
            print(f'value_num_count: {value_num_count}')

            offset_zero = read_uint64(file)
            offsets = [offset_zero]
            offsets.extend(read_uint64s(file, 2 * epi_num))

            # Further processing for sparse format...
            # Assuming the file pointer is now at the start of the index data
            # all_index_order = []
            beta_indices = []
            se_indices = []

            for i in range(epi_num):
                # Calculate the number of indices for beta and se values
                num_beta_indices = offsets[i * 2 + 1] - offsets[i * 2]
                num_se_indices = offsets[i * 2 + 2] - offsets[i * 2 + 1]

                # Read the indices for beta and se values
                beta_indices.append(read_uint32s(file, num_beta_indices))
                se_indices.append(read_uint32s(file, num_se_indices))

                # all_index_order.extend(beta_indices[-1])
                # all_index_order.extend(se_indices[-1])

            # Now read the actual beta and se values based on the indices

            prob_dict = {}

            for i in range(epi_num):
                # beta_values = {}
                # se_values = {}
                num_beta_values = len(beta_indices[i])
                num_se_values = len(se_indices[i])
                beta_values = read_floats(file, num_beta_values)
                se_values = read_floats(file, num_se_values)
                # for index in beta_indices[i]:
                #     beta_values[index] = struct.unpack('<f', file.read(4))[0]
                #
                # for index in se_indices[i]:
                #     se_values[index] = struct.unpack('<f', file.read(4))[0]

                # prob_dict[i] = [beta_values, se_values]
                prob_dict[i] = pd.DataFrame({'beta': beta_values, 'se': se_values}, index=beta_indices[i],
                                            dtype='float16')
            return prob_dict

        else:
            raise ValueError("File format not recognized")


# %%
def parse_besd_one_gene(file_path,
                        probe_index,
                        ):
    with open(file_path, 'rb') as file:
        # open(epi_file_path, 'r') as epi_file, \
        # open(esi_file_path, 'r') as esi_file:

        # Read basic info
        file_format_tmp = read_int32(file)
        file_format = file_format_tmp
        _ = read_int32(file)  # sample number
        esi_num = read_int32(file)
        epi_num = read_int32(file)
        _ = [read_int32(file) for _ in range(12)]  # reserved

        # Check if esi_num and epi_num match the line counts of respective files
        # assert esi_num == sum(1 for _ in esi_file)
        # assert epi_num == sum(1 for _ in epi_file)

        if file_format == 5:  # Dense format
            raise ValueError("Dense format not supported for single gene parsing")
        elif file_format == 3:  # Sparse format
            print("Reading sparse format...")
            # Initialize value_num_count and offsets
            value_num_count = read_uint64(file)
            print(f'value_num_count: {value_num_count}')
            offset_zero = read_uint64(file)
            offsets = [offset_zero]
            offsets.extend(read_uint64s(file, 2 * epi_num))

            # Further processing for sparse format...
            # Assuming the file pointer is now at the start of the index data
            position_beta = offsets[probe_index * 2]
            position_se = offsets[probe_index * 2 + 1]
            length_beta = offsets[probe_index * 2 + 1] - offsets[probe_index * 2]

            remain_index_byte = value_num_count * 4 - position_se * 4
            file.seek(position_beta * 4, 1)
            beta_indices = read_uint32s(file, length_beta)
            # se_indices = read_uint32s(file, length_beta)
            # Now read the actual beta and se values based on the indices
            file.seek(remain_index_byte + position_beta * 4, 1)

            beta_values = read_floats(file, length_beta)
            se_values = read_floats(file, length_beta)

            df = pd.DataFrame({'beta': beta_values, 'se': se_values}, index=beta_indices)
        return df

#%%
if __name__ == '__main__':
    # example usage
    # QTL_path ...
    QTL_file_prefix = 'data/Wole_Blood_sQTL_all_chr1'
    besd_file_path = '%s.besd' % QTL_file_prefix
    esi_file_path = '%s.esi' % QTL_file_prefix
    epi_file_path = '%s.epi' % QTL_file_prefix

    esi_df = parse_esi_file(esi_file_path)
    epi_df = parse_epi_file(epi_file_path)

    #%% example for fetch probe TEKT4P2
    probe_index = epi_df[epi_df['probe'] == 'chr1:17055:17233:clu_40981:ENSG00000227232.5'].index[0]

    gene_df = parse_besd_one_gene(besd_file_path, probe_index)

    print(gene_df.join(esi_df))

    #%% test the average time for fetching one gene
    import time
    time_list = []
    for probe_index in epi_df.index:
        start = time.perf_counter()
        gene_df = parse_besd_one_gene(besd_file_path, probe_index)
        time_list.append(time.perf_counter() - start)

    #%%
    # draw the time distribution
    import matplotlib.pyplot as plt
    plt.hist(time_list, bins=200)
    plt.title('Time distribution for fetching one probe (unit: s)')
    plt.show()
