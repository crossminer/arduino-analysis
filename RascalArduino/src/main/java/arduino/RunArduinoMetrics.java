package arduino;

import java.io.PrintWriter;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

import org.eclipse.core.internal.preferences.ImmutableMap;
import org.rascalmpl.debug.IRascalMonitor;
import org.rascalmpl.interpreter.Evaluator;
import org.rascalmpl.interpreter.NullRascalMonitor;
import org.rascalmpl.interpreter.env.GlobalEnvironment;
import org.rascalmpl.interpreter.env.ModuleEnvironment;
import org.rascalmpl.interpreter.load.StandardLibraryContributor;
import org.rascalmpl.interpreter.result.AbstractFunction;
import org.rascalmpl.values.ValueFactoryFactory;

import io.usethesource.vallang.IReal;
import io.usethesource.vallang.IValue;
import io.usethesource.vallang.IValueFactory;

public class RunArduinoMetrics {
	private final String clairPath = Paths.get("clair/src/").toAbsolutePath().toString();
	private final IValueFactory vf = ValueFactoryFactory.getValueFactory();
	private final Evaluator eval;

	public RunArduinoMetrics() {
		eval = createRascalEvaluator(vf);
	}

	public IValue cppM3(String filePath) {
		Map<String, IValue> kwParams = new HashMap<>();
		kwParams.put("includes", vf.list());
		return eval.call("cppM3", "arduino::Metrics", kwParams, vf.sourceLocation(filePath));
	}

	public IValue compute(String filePath, String metricName) {
		IValue m3 = cppM3(filePath);
		return eval.call(metricName, m3);
	}

	public float similarity(String orig, String fork) {
		IValue origM3 = cppM3(orig);
		IValue forkM3 = cppM3(fork);
		IReal res = (IReal) eval.call("similarity", origM3, forkM3);
		return res.floatValue();
	}

	public List<String> getAllMetricNames() {
		return getAllMetricFunctions().stream().map(AbstractFunction::getName).collect(Collectors.toList());
	}

	private List<AbstractFunction> getAllMetricFunctions() {
		List<AbstractFunction> result = new ArrayList<>();
		ModuleEnvironment module = eval.getHeap().getModule("arduino::Metrics");

		// Mind the assumptions
		module.getFunctions().forEach(e -> {
			Optional<AbstractFunction> metric = e.getSecond().stream().filter(f -> f.hasTag("metric")).findAny();

			if (metric.isPresent())
				result.add(metric.get());
		});

		return result;
	}

	private Evaluator createRascalEvaluator(IValueFactory vf) {
		IRascalMonitor mon = new NullRascalMonitor();
		GlobalEnvironment heap = new GlobalEnvironment();
		ModuleEnvironment module = new ModuleEnvironment("$rascal-arduino$", heap);
		PrintWriter stderr = new PrintWriter(System.err);
		PrintWriter stdout = new PrintWriter(System.out);
		Evaluator eval = new Evaluator(vf, stderr, stdout, module, heap);
		Path metricsPath = Paths.get("src/").toAbsolutePath();

		eval.addRascalSearchPathContributor(StandardLibraryContributor.getInstance());
		eval.addRascalSearchPath(vf.sourceLocation(metricsPath.toString()));
		eval.addRascalSearchPath(vf.sourceLocation(clairPath));
		eval.addClassLoader(getClass().getClassLoader());

		eval.doImport(mon, "lang::cpp::AST");
		eval.doImport(mon, "lang::cpp::M3");
		eval.doImport(mon, "arduino::Metrics");

		return eval;
	}

	public static void main(String[] args) {
		if (args.length < 1 || args.length > 2) {
			System.err.println("Usage [metrics]:       ./arduino </path/to/Arduino/module>");
			System.err.println("Usage [fork analysis]: ./arduino </path/to/Arduino/module/original> </path/to/Arduino/module/fork>");
			System.exit(-1);
		}

		RunArduinoMetrics run = new RunArduinoMetrics();

		if (args.length == 1) {
			String filePath = args[0];

			run.getAllMetricNames().forEach(name -> {
				System.out.println(String.format("Computing %s on %s...", name, filePath));
				System.out.println("\tresult = " + run.compute(filePath, name));
				System.out.println();
			});
		} else if (args.length == 2) {
			String orig = args[0];
			String fork = args[1];

			System.out.println(String.format("Fork analysis between %s and %s...", orig, fork));
			System.out.println("Score: " + run.similarity(orig, fork));
		}
	}
}
