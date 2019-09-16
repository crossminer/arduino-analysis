package arduino;

import java.io.PrintWriter;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.rascalmpl.debug.IRascalMonitor;
import org.rascalmpl.interpreter.Evaluator;
import org.rascalmpl.interpreter.NullRascalMonitor;
import org.rascalmpl.interpreter.env.GlobalEnvironment;
import org.rascalmpl.interpreter.env.ModuleEnvironment;
import org.rascalmpl.interpreter.load.StandardLibraryContributor;
import org.rascalmpl.interpreter.result.AbstractFunction;
import org.rascalmpl.values.ValueFactoryFactory;

import io.usethesource.vallang.IValue;
import io.usethesource.vallang.IValueFactory;

public class RunArduinoMetrics {
	private final String clairPath = Paths.get("clair/src/").toAbsolutePath().toString();
	private final IValueFactory vf = ValueFactoryFactory.getValueFactory();
	private final Evaluator eval;

	public RunArduinoMetrics() {
		eval = createRascalEvaluator(vf);
	}

	public IValue compute(String filePath, String metricName) {
		IValue m3 = eval.call("cppM3", vf.sourceLocation(filePath));
		return eval.call(metricName, m3);
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
		if (args.length != 1) {
			System.err.println("Usage: ./arduino </path/to/Arduino/sketch>");
			System.exit(-1);
		}

		RunArduinoMetrics run = new RunArduinoMetrics();

		String filePath = args[0];

		run.getAllMetricNames().forEach(name -> {
			System.out.println(String.format("Computing %s on %s...", name, filePath));
			System.out.println("\tresult = " + run.compute(filePath, name));
		});
	}
}
