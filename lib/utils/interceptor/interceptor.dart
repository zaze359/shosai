/// Description : 拦截器
/// @author zaze
/// @date 2022/8/5 - 4:58
abstract class Interceptor<I, O> {
  /// 拦截处理
  O intercept(Chain<I, O> chain);
}

/// Description : 责任链
/// @author zaze
/// @date 2022/8/5 - 4:58
abstract class Chain<I, O> {
  /// 获取输入
  I input();

  /// 处理输入并返回结果
  O process(I input);
}

/// Description : 责任链处理器
/// @author zaze
/// @date 2022/8/5 - 4:57
class RealInterceptorChain<I, O> implements Chain<I, O> {

  final List<Interceptor<I, O>> interceptors;
  final I _input;
  int index = 0;

  RealInterceptorChain(this.interceptors, this._input, {this.index = 0});

  @override
  I input() {
    return _input;
  }

  @override
  O process(I input) {
    if (index >= interceptors.length) {
      throw AssertionError("index$index >= ${interceptors.length}");
    }
    var next = RealInterceptorChain(interceptors, input, index: index + 1);
    return interceptors[index].intercept(next);
  }
}
