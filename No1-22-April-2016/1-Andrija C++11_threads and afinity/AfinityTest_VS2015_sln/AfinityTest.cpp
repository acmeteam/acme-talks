// AfinityTest.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <thread>
#include <iostream>
#include <vector>
#include <string>
#include <mutex>
#include <algorithm>
#include <numeric>
#include <random>
#include <chrono>

using namespace std::chrono;
std::mutex iomutex;
void Test1()
{
	unsigned num_cpus = std::thread::hardware_concurrency();
	std::cout << "Launching " << num_cpus << " threads\n";
	// A mutex ensures orderly access to std::cout from multiple threads.
	std::mutex iomutex;
	std::vector<std::thread> threads(num_cpus);
	for (unsigned i = 0; i < num_cpus; ++i) {
		threads[i] = std::thread([&iomutex, i] {
			{
				// Use a lexical scope and lock_guard to safely lock the mutex only for
				// the duration of std::cout usage.
				std::lock_guard<std::mutex> iolock(iomutex);
				std::cout << "Thread #" << i << " is running\n";
			}
			// Simulate important work done by the tread by sleeping for a bit...
			std::this_thread::sleep_for(std::chrono::milliseconds(200));
		});
	}
	for (auto& t : threads) {
		t.join();
	}
}
void Test2()
{
	constexpr unsigned num_threads = 4;
	// A mutex ensures orderly access to std::cout from multiple threads.
	std::mutex iomutex;
	std::vector<std::thread> threads(num_threads);
	for (unsigned i = 0; i < num_threads; ++i) {
		threads[i] = std::thread([&iomutex, i] {
			unsigned counter = 10;
			while (counter--) {
				{
					// Use a lexical scope and lock_guard to safely lock the mutex only
					// for the duration of std::cout usage.
					std::lock_guard<std::mutex> iolock(iomutex);
					;
					std::cout << "Thread #" << i << ": on CPU " << /*sched_getcpu()*/  GetCurrentProcessorNumber()  << "\n";
				}
				// Simulate important work done by the tread by sleeping for a bit...
				std::this_thread::sleep_for(std::chrono::milliseconds(900));
			}
		});
	}
	for (auto& t : threads) {
		t.join();
	}
}
void Test3()
{
	std::mutex iomutex;
	std::thread t = std::thread([&iomutex] {
		{
			std::lock_guard<std::mutex> iolock(iomutex);
			std::cout << "Thread: my id = " << std::this_thread::get_id() << "\n" << " my pthread id = " << GetCurrentThreadId() << "\n";
		}
	});



	{
		std::lock_guard<std::mutex> iolock(iomutex);
		std::cout << "Launched t: id = " << t.get_id() << "\n"<< " native_handle = " << t.native_handle() << "\n";
	}
	t.join();
}
void Test4()
{
	int num_threads = 8;
	std::mutex iomutex;
	std::vector<std::thread> threads(num_threads);
	for (unsigned i = 0; i < num_threads; ++i) {
		threads[i] = std::thread([&iomutex, i] {
			std::this_thread::sleep_for(std::chrono::milliseconds(20));
			while (1) {
				{
					// Use a lexical scope and lock_guard to safely lock the mutex only
					// for the duration of std::cout usage.
					std::lock_guard<std::mutex> iolock(iomutex);
					std::cout << "Thread #"<< i << ": on CPU " << GetCurrentProcessorNumber() << "\n";
				}
				// Simulate important work done by the tread by sleeping for a bit...
				std::this_thread::sleep_for(std::chrono::milliseconds(900));
			}
		});
		// Create a cpu_set_t object representing a set of CPUs. Clear it and mark
		// only CPU i as set.
		int mask = (1 << i);
		SetThreadAffinityMask(threads[i].native_handle(), mask);

	}
	for (auto& t : threads) {
		t.join();
	}
}


namespace Workload
{
	using WorkloadFunc = std::function<void(const std::vector<float>&, float&)>;
	using hires_clock = std::chrono::high_resolution_clock;
	using duration_ms = std::chrono::duration<double, std::milli>;

	void workload_fpchurn(const std::vector<float>& data, float& result) {
		constexpr size_t NUM_ITERS = 10 * 1000 * 1000;
		auto t1 = hires_clock::now();
		float rt = 0;
		for (size_t i = 0; i < NUM_ITERS; ++i) {
			float item = data[i];
			float l = std::log(item);
			if (l > rt) {
				l = std::sin(l);
			}
			else {
				l = std::cos(l);
			}

			if (l > rt - 2.0) {
				l = std::exp(l);
			}
			else {
				l = std::exp(l + 1.0);
			}
			rt += l;
		}
		result = rt;

		{
			auto t2 = hires_clock::now();
			std::lock_guard<std::mutex> iolock(iomutex);
			std::cout << __func__ << " [CPU " << GetCurrentProcessorNumber() << "]:\n";
			std::cout << "  elapsed: " << duration_ms(t2 - t1).count() << " ms\n";
		}
	}
	void workload_sin(const std::vector<float>& data, float& result) {
		auto t1 = hires_clock::now();
		float rt = 0;
		for (size_t i = 0; i < data.size(); ++i) {
			rt += std::sin(data[i]);
		}
		result = rt;

		{
			auto t2 = hires_clock::now();
			std::lock_guard<std::mutex> iolock(iomutex);
			std::cout << __func__ << " [cpu " << GetCurrentProcessorNumber() << "]:\n";
			std::cout << "  processed items: " << data.size() << "\n";
			std::cout << "  elapsed: " << duration_ms(t2 - t1).count() << " ms\n";
			std::cout << "  result: " << result << "\n";
		}
	}
	void workload_accum(const std::vector<float>& data, float& result) {
		auto t1 = hires_clock::now();
		float rt = 0;
		for (size_t i = 0; i < data.size(); ++i) {
			// On x86-64, this should generate a loop of data.size ADDSS instructions,
			// all adding up into the same xmm register. If built with -Ofast
			// (-ffast-math), the compiler will be willing to perform unsafe FP
			// optimizations and will vectorize the loop into data.size/4 ADDPS
			// instructions. Note that this changes the order in which the floats are
			// added, which is unsafe because FP addition is not associative.
			rt += data[i];
		}
		result = rt;

		{
			auto t2 = hires_clock::now();
			std::lock_guard<std::mutex> iolock(iomutex);
			std::cout << __func__ << " [cpu " << GetCurrentProcessorNumber() << "]:\n";
			std::cout << "  processed items: " << data.size() << "\n";
			std::cout << "  elapsed: " << duration_ms(t2 - t1).count() << " ms\n";
			std::cout << "  result: " << result << "\n";
		}
	}
	void workload_unrollaccum4(const std::vector<float>& data, float& result) {
		auto t1 = hires_clock::now();
		if (data.size() % 4 != 0) {
			std::cerr
				<< "ERROR in " << __func__ << ": data.size " << data.size() << "\n";
		}
		float rt0 = 0;
		float rt1 = 0;
		float rt2 = 0;
		float rt3 = 0;
		for (size_t i = 0; i < data.size(); i += 4) {
			// This unrolling performs manual break-down of dependencies on a single xmm
			// register that happens in workload_accum. It should be faster because
			// distinct ADDSS instructions will accumulate into separate registers. It
			// is also unsafe for the same reasons as described above.
			rt0 += data[i];
			rt1 += data[i + 1];
			rt2 += data[i + 2];
			rt3 += data[i + 3];
		}
		result = rt0 + rt1 + rt2 + rt3;

		{
			auto t2 = hires_clock::now();
			std::lock_guard<std::mutex> iolock(iomutex);
			std::cout << __func__ << " [cpu " << GetCurrentProcessorNumber() << "]:\n";
			std::cout << "  processed items: " << data.size() << "\n";
			std::cout << "  elapsed: " << duration_ms(t2 - t1).count() << " ms\n";
			std::cout << "  result: " << result << "\n";
		}
	}
	void workload_unrollaccum8(const std::vector<float>& data, float& result) {
		auto t1 = hires_clock::now();
		if (data.size() % 8 != 0) {
			std::cerr
				<< "ERROR in " << __func__ << ": data.size " << data.size() << "\n";
		}
		float rt0 = 0;
		float rt1 = 0;
		float rt2 = 0;
		float rt3 = 0;
		float rt4 = 0;
		float rt5 = 0;
		float rt6 = 0;
		float rt7 = 0;
		for (size_t i = 0; i < data.size(); i += 8) {
			rt0 += data[i];
			rt1 += data[i + 1];
			rt2 += data[i + 2];
			rt3 += data[i + 3];
			rt4 += data[i + 4];
			rt5 += data[i + 5];
			rt6 += data[i + 6];
			rt7 += data[i + 7];
		}
		result = rt0 + rt1 + rt2 + rt3 + rt4 + rt5 + rt6 + rt7;

		{
			auto t2 = hires_clock::now();
			std::lock_guard<std::mutex> iolock(iomutex);
			std::cout << __func__ << " [cpu " << GetCurrentProcessorNumber() << "]:\n";
			std::cout << "  processed items: " << data.size() << "\n";
			std::cout << "  elapsed: " << duration_ms(t2 - t1).count() << " ms\n";
			std::cout << "  result: " << result << "\n";
		}
	}
	void workload_stdaccum(const std::vector<float>& data, float& result) {
		auto t1 = hires_clock::now();
		result = std::accumulate(data.begin(), data.end(), 0.0f);

		{
			auto t2 = hires_clock::now();
			std::lock_guard<std::mutex> iolock(iomutex);
			std::cout << __func__ << " [cpu " << GetCurrentProcessorNumber() << "]:\n";
			std::cout << "  processed items: " << data.size() << "\n";
			std::cout << "  elapsed: " << duration_ms(t2 - t1).count() << " ms\n";
			std::cout << "  result: " << result << "\n";
		}
	}


	// Create a vector filled with N floats uniformly distributed in the range
	// (-1.0,1.0)
	std::vector<float> make_input_array(int N) {
		std::random_device rd;
		std::mt19937 gen(rd());
		std::uniform_real_distribution<float> dis(-1.0f, 1.0f);

		std::vector<float> vf(N);
		for (size_t i = 0; i < vf.size(); ++i) {
			vf[i] = dis(gen);
		}

		return vf;
	}

	void pin_thread_to_cpu(std::thread& t, int cpu_num) {
		int mask =  1 << cpu_num;
		SetThreadAffinityMask(t.native_handle(), mask);
	}
}


void Test5(int argc, const char** argv)
{
	int num_workloads = argc / 2;
	std::vector<float> results(num_workloads);
	std::vector<std::thread> threads(num_workloads);

	constexpr size_t INPUT_SIZE = 20 * 1000 * 1000;
	auto t1 = Workload::hires_clock::now();


	std::vector<std::vector<float>> inputs(num_workloads + 1);
	for (int i = 0; i < num_workloads; ++i) {
		inputs[i] = Workload::make_input_array(INPUT_SIZE);
	}
	std::cout << "Created " << num_workloads + 1 << " input arrays "<< "; elapsed: " << duration_cast<microseconds>(Workload::hires_clock::now() - t1).count() << " ms\n";

	for (int i = 1; i < argc; i += 2) {
		Workload::WorkloadFunc func;
		std::string workload_name = argv[i];
		if (workload_name == "fpchurn") {
			func = Workload::workload_fpchurn;
		}
		else if (workload_name == "sin") {
			func = Workload::workload_sin;
		}
		else if (workload_name == "accum") {
			func = Workload::workload_accum;
		}
		else if (workload_name == "unrollaccum4") {
			func = Workload::workload_unrollaccum4;
		}
		else if (workload_name == "unrollaccum8") {
			func = Workload::workload_unrollaccum8;
		}
		else if (workload_name == "stdaccum") {
			func = Workload::workload_stdaccum;
		}
		else {
			std::cerr << "unknown workload: " << argv[i] << "\n";
			return;
		}

		int cpu_num;
		if (i + 1 >= argc) {
			cpu_num = 0;
		}
		else {
			cpu_num = std::atoi(argv[i + 1]);
		}

		{
			std::lock_guard<std::mutex> iolock(iomutex);
			std::cout << "Spawning workload '" << workload_name << "' on CPU " << cpu_num << "\n";
		}

		int nworkload = i / 2;
		threads[nworkload] = std::thread(func, std::cref(inputs[nworkload]), std::ref(results[nworkload]));
		Workload::pin_thread_to_cpu(threads[nworkload], cpu_num);
	}

	// All the threads were launched in parallel in the loop above. Now wait for
	// all of them to finish.
	for (auto& t : threads) {
		t.join();
	}
}
int main(int argc, const char** argv)
{
	//Test1();
	//Test2();
	//Test3();
	//Test4();
	Test5(argc, argv);

    return 0;
}

