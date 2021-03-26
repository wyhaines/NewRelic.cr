@[Link(ldflags: "-static -L/home/wyhaines/.ghq/github.com/wyhaines/NewRelic.cr/c-sdk -lnewrelic")]

# This implements the low level interface between Crystal and the
# C SDK. It should generally not be used directly. Instead, programs
# should generally operate through the interface provided in NewRelic.
lib NewRelicExt
  fun configure_log = newrelic_configure_log(filename : LibC::Char*, level : LoglevelT) : Bool
  enum X_NewrelicLoglevelT
    NewrelicLogError   = 0
    NewrelicLogWarning = 1
    NewrelicLogInfo    = 2
    NewrelicLogDebug   = 3
  end
  alias LoglevelT = X_NewrelicLoglevelT
  fun init = newrelic_init(daemon_socket : LibC::Char*, time_limit_ms : LibC::Int) : Bool

  fun create_app_config = newrelic_create_app_config(app_name : LibC::Char*, license_key : LibC::Char*) : AppConfigT*

  struct X_NewrelicAppConfigT
    app_name : LibC::Char[255]
    license_key : LibC::Char[255]
    redirect_collector : LibC::Char[100]
    log_filename : LibC::Char[512]
    log_level : LoglevelT
    transaction_tracer : TransactionTracerConfigT
    datastore_tracer : DatastoreSegmentConfigT
    distributed_tracing : DistributedTracingConfigT
    span_events : SpanEventConfigT
  end

  type AppConfigT = X_NewrelicAppConfigT

  struct X_NewrelicTransactionTracerConfigT
    enabled : Bool
    threshold : TransactionTracerThresholdT
    duration_us : TimeUsT
    stack_trace_threshold_us : TimeUsT
    datastore_reporting : X_NewrelicTransactionTracerConfigTDatastoreReporting
  end

  type TransactionTracerConfigT = X_NewrelicTransactionTracerConfigT
  enum X_NewrelicTransactionTracerThresholdT
    NewrelicThresholdIsApdexFailing = 0
    NewrelicThresholdIsOverDuration = 1
  end
  type TransactionTracerThresholdT = X_NewrelicTransactionTracerThresholdT
  type X__Uint64T = LibC::ULong
  type Uint64T = X__Uint64T
  type TimeUsT = Uint64T

  struct X_NewrelicTransactionTracerConfigTDatastoreReporting
    enabled : Bool
    record_sql : TtRecordsqlT
    threshold_us : TimeUsT
  end

  enum X_NewrelicTtRecordsqlT
    NewrelicSqlOff        = 0
    NewrelicSqlRaw        = 1
    NewrelicSqlObfuscated = 2
  end
  alias TtRecordsqlT = X_NewrelicTtRecordsqlT

  struct X_NewrelicDatastoreSegmentConfigT
    instance_reporting : Bool
    database_name_reporting : Bool
  end

  type DatastoreSegmentConfigT = X_NewrelicDatastoreSegmentConfigT

  struct X_NewrelicDistributedTracingConfigT
    enabled : Bool
  end

  type DistributedTracingConfigT = X_NewrelicDistributedTracingConfigT

  struct X_NewrelicSpanEventConfigT
    enabled : Bool
  end

  type SpanEventConfigT = X_NewrelicSpanEventConfigT
  fun destroy_app_config = newrelic_destroy_app_config(config : AppConfigT**) : Bool
  fun create_app = newrelic_create_app(config : AppConfigT*, timeout_ms : LibC::UShort) : AppT
  type AppT = Void*
  fun destroy_app = newrelic_destroy_app(app : AppT*) : Bool
  fun start_web_transaction = newrelic_start_web_transaction(app : AppT, name : LibC::Char*) : TxnT
  type TxnT = Void*
  fun start_non_web_transaction = newrelic_start_non_web_transaction(app : AppT, name : LibC::Char*) : TxnT
  fun set_transaction_timing = newrelic_set_transaction_timing(transaction : TxnT, start_time : TimeUsT, duration : TimeUsT) : Bool
  fun end_transaction = newrelic_end_transaction(transaction_ptr : TxnT*) : Bool
  fun add_attribute_int = newrelic_add_attribute_int(transaction : TxnT, key : LibC::Char*, value : LibC::Int) : Bool
  fun add_attribute_long = newrelic_add_attribute_long(transaction : TxnT, key : LibC::Char*, value : LibC::Long) : Bool
  fun add_attribute_double = newrelic_add_attribute_double(transaction : TxnT, key : LibC::Char*, value : LibC::Double) : Bool
  fun add_attribute_string = newrelic_add_attribute_string(transaction : TxnT, key : LibC::Char*, value : LibC::Char*) : Bool
  fun notice_error = newrelic_notice_error(transaction : TxnT, priority : LibC::Int, errmsg : LibC::Char*, errclass : LibC::Char*)
  fun start_segment = newrelic_start_segment(transaction : TxnT, name : LibC::Char*, category : LibC::Char*) : SegmentT
  type SegmentT = Void*
  fun start_datastore_segment = newrelic_start_datastore_segment(transaction : TxnT, params : DatastoreSegmentParamsT*) : SegmentT

  struct X_NewrelicDatastoreSegmentParamsT
    product : LibC::Char*
    collection : LibC::Char*
    operation : LibC::Char*
    host : LibC::Char*
    port_path_or_id : LibC::Char*
    database_name : LibC::Char*
    query : LibC::Char*
  end

  type DatastoreSegmentParamsT = X_NewrelicDatastoreSegmentParamsT
  fun start_external_segment = newrelic_start_external_segment(transaction : TxnT, params : ExternalSegmentParamsT*) : SegmentT

  struct X_NewrelicExternalSegmentParamsT
    uri : LibC::Char*
    procedure : LibC::Char*
    library : LibC::Char*
  end

  type ExternalSegmentParamsT = X_NewrelicExternalSegmentParamsT
  fun set_segment_parent = newrelic_set_segment_parent(segment : SegmentT, parent : SegmentT) : Bool
  fun set_segment_parent_root = newrelic_set_segment_parent_root(segment : SegmentT) : Bool
  fun set_segment_timing = newrelic_set_segment_timing(segment : SegmentT, start_time : TimeUsT, duration : TimeUsT) : Bool
  fun end_segment = newrelic_end_segment(transaction : TxnT, segment_ptr : SegmentT*) : Bool
  fun create_custom_event = newrelic_create_custom_event(event_type : LibC::Char*) : CustomEventT
  type CustomEventT = Void*
  fun discard_custom_event = newrelic_discard_custom_event(event : CustomEventT*)
  fun record_custom_event = newrelic_record_custom_event(transaction : TxnT, event : CustomEventT*)
  fun custom_event_add_attribute_int = newrelic_custom_event_add_attribute_int(event : CustomEventT, key : LibC::Char*, value : LibC::Int) : Bool
  fun custom_event_add_attribute_long = newrelic_custom_event_add_attribute_long(event : CustomEventT, key : LibC::Char*, value : LibC::Long) : Bool
  fun custom_event_add_attribute_double = newrelic_custom_event_add_attribute_double(event : CustomEventT, key : LibC::Char*, value : LibC::Double) : Bool
  fun custom_event_add_attribute_string = newrelic_custom_event_add_attribute_string(event : CustomEventT, key : LibC::Char*, value : LibC::Char*) : Bool
  fun version = newrelic_version : LibC::Char*
  fun record_custom_metric = newrelic_record_custom_metric(transaction : TxnT, metric_name : LibC::Char*, milliseconds : LibC::Double) : Bool
  fun ignore_transaction = newrelic_ignore_transaction(transaction : TxnT) : Bool
  fun create_distributed_trace_payload = newrelic_create_distributed_trace_payload(transaction : TxnT, segment : SegmentT) : LibC::Char*
  fun accept_distributed_trace_payload = newrelic_accept_distributed_trace_payload(transaction : TxnT, payload : LibC::Char*, transport_type : LibC::Char*) : Bool
  fun create_distributed_trace_payload_httpsafe = newrelic_create_distributed_trace_payload_httpsafe(transaction : TxnT, segment : SegmentT) : LibC::Char*
  fun accept_distributed_trace_payload_httpsafe = newrelic_accept_distributed_trace_payload_httpsafe(transaction : TxnT, payload : LibC::Char*, transport_type : LibC::Char*) : Bool
  fun set_transaction_name = newrelic_set_transaction_name(transaction : TxnT, transaction_name : LibC::Char*) : Bool
end
